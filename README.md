# zoomAppContext for ColdFusion

Use this when creating a Zoom App to run in the Zoom Client.

https://marketplace.zoom.us/docs/zoom-apps/zoomappcontext/

When a user attempts to open your app from the Zoom client, Zoom sends an HTTP request to your app’s Home URL and upon successfully completing the request, it renders the content of the Home URL in the Zoom client.

The request sent to your Home URL includes X-Zoom-App-Context header which is an AES-GCM encrypted JSON object with information about the user and the context in which the user opened the app.

The value of the header contains a base64-encoded string that includes the initialization vector, additional authentication data, the cipher text itself, and an authentication tag which are used as inputs for the decryption process.

The header also includes the length of each input in bytes:

[ivLength: 1 byte][iv][aadLength: 2 bytes][aad][cipherTextLength: 4 bytes][cipherText][tag: 16 bytes]

Thus, to parse the initialization vector (iv), you would read the first byte of the sequence to get its length. Then, you would read the next n bytes in the sequence to get the actual value of iv. To get the aad, you would read the 2 bytes following the iv to get its length, and then the next m bytes in the sequence to get the aad value. The tag at the end of the sequence has a predetermined length of 16 bytes, so its length is not included.

Per usual, Zoom gives several code samples to accomplish the task but does not include ColdFusion.  Frustrating.  So, here it is.
