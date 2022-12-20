<!--- -------------------------------------------------------------------------------------------------------------------------------------------------------------- --->
<!--- 
https://marketplace.zoom.us/docs/zoom-apps/zoomappcontext/
When a user attempts to open your app from the Zoom client, Zoom sends an HTTP request to your app’s Home URL and upon successfully completing the request, it renders the content of the Home URL in the Zoom client.

The request sent to your Home URL includes X-Zoom-App-Context header which is an AES-GCM encrypted JSON object with information about the user and the context in which the user opened the app.
 --->
<!--- -------------------------------------------------------------------------------------------------------------------------------------------------------------- --->
<cffunction name="decryptZoomHeader" output="No">
	<cfargument name="encryptedHdr" required="Yes">
	<cfargument name="cSecret" required="no">

	<cfset var ret = {error="NONE",user={}}>
	
	<cftry>

		<cfif isDefined("arguments.encryptedHdr") AND len(arguments.encryptedHdr)>

			<cfset context = arguments.encryptedHdr>

			<cfset ivByteLen = 1>
			<cfset aadByteLen = 2>
			<cfset encryptByteLen = 4>
			<cfset tagByteLen = 16>

			<cfset contextByte = JavaCast("string", context).getBytes()>
			<cfset plainKey = JavaCast("string", (isDefined('arguments.cSecret')?arguments.cSecret:clientSecret)).getBytes()>

			<cfset b64 = createObject("Java", "org.apache.commons.codec.binary.Base64").init().decodeBase64(contextByte)>
			<cfset plainKey = createObject("Java", "org.apache.commons.codec.digest.DigestUtils").sha256(plainKey)>

			<!--- ivlength is 1st byte --->
			<cfset ivLengthBin = javacast('byte[]',arraySlice(b64,1,ivByteLen))>
			<cfset ivLength = createObject("Java", "java.io.ByteArrayInputStream").init(ivLengthBin)>
			<cfset ivLength = ivLength.read()>
			<cfset ivIdx = 2><!--- Start at 2...one byte after length --->
			<cfset iv = javacast('byte[]',arraySlice(b64,ivIdx,ivLength))>
		
			<cfset aadLenIdx = ivLength + ivIdx>
			<cfset aadLengthBin = javacast('byte[]',arraySlice(b64,aadLenIdx,aadByteLen))>
			<cfset aadLength = createObject("Java", "java.io.ByteArrayInputStream").init(aadLengthBin)>
			<cfset aadLength = aadLength.read()>
			<cfif isNumeric(aadLength) AND aadLength GT 0>
				<cfset aadIdx = aadLenIdx + aadByteLen>
				<cfset aad = javacast('byte[]',arraySlice(b64,aadIdx,aadLength))>
			</cfif>

			<cfset encryptLengthIdx = aadLenIdx + aadByteLen + aadLength>
			<cfset encryptLengthbin = javacast('byte[]',arraySlice(b64,encryptLengthIdx,encryptByteLen))>
			<cfset encryptLength = createObject("Java", "java.io.ByteArrayInputStream").init(encryptLengthbin)>
			<cfset encryptLength = encryptLength.read()>
			<cfset encrypt1Idx = encryptLengthIdx + encryptByteLen>
			<cfset encrypt1 = javacast('byte[]',arraySlice(b64,encrypt1Idx,encryptLength+16))>

			<cfset gcmParameterSpec = createObject("java","javax.crypto.spec.GCMParameterSpec").init(128,iv)> <!--- {128, 120, 112, 104, 96}  --->

			<cfset secretKey = createObject("java","javax.crypto.spec.SecretKeySpec").init(plainKey,"AES")>

			<cfset cipher = createObject("java","javax.crypto.Cipher").getInstance("AES/GCM/NoPadding")>

			<cfset cipher.init(Cipher.DECRYPT_MODE, secretKey, gcmParameterSpec)>

			<cfif aadLength GT 0>
				<cfset cipher.updateAAD(aad)>
			</cfif>

			<cfset finalDecrypt = cipher.doFinal(encrypt1)>

			<cfset plainContext = createObject("Java", "java.lang.String").init(finalDecrypt)>

			<cfif isJSON(plainContext)>
				<cfset ret.user = deSerializeJSON(plainContext)>
			</cfif>

		<cfelse>
			<cfset ret.error = "No header data">
		</cfif>

		<cfcatch type="any">
			
			<cfset ret.error = cfcatch.error>

		</cfcatch>
	</cftry>

	<cfreturn ret>

</cffunction>
