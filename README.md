# zoomAppContext

When a user attempts to open your app from the Zoom client, Zoom sends an HTTP request to your app’s Home URL and upon successfully completing the request, it renders the content of the Home URL in the Zoom client.

The request sent to your Home URL includes X-Zoom-App-Context header which is an AES-GCM encrypted JSON object with information about the user and the context in which the user opened the app.
