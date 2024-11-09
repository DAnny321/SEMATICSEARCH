codeunit 80310 "GPT Semantic Request Vector"
{

    /**
     * This procedure sends a user question to an external service and retrieves a response.
     *
     * @param UserQuestion The question asked by the user.
     * @param BobResponse The response received from the external service.
     * @param index The index name used in the Azure Search service.
     *
     * Variables:
     * - client: HttpClient instance used to send the HTTP request.
     * - request: HttpRequestMessage instance representing the HTTP request.
     * - response: HttpResponseMessage instance representing the HTTP response.
     * - contentHeaders: HttpHeaders instance representing the headers of the HTTP content.
     * - content: HttpContent instance representing the content of the HTTP request.
     * - JsonResponse: Text variable to store the JSON response from the external service.
     * - templateResponse: Label used for formatting the complete response.
     * - JsonBody: JsonObject instance representing the JSON body of the request.
     * - payload: Text variable to store the payload of the HTTP request.
     * - format: Text variable to store the format instructions for the response.
     *
     * The procedure constructs a JSON payload with the user question and format instructions,
     * sets the necessary headers, and sends the request to the external service.
     * It then reads the JSON response and extracts the relevant content to populate BobResponse.
     * If the HTTP status code is not 200 or 202, an error is raised with the JSON response.
     */
    procedure GetAnswer(var UserQuestion: text; var BobResponse: text; Cosine: Boolean)
    var
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
        JsonResponse: text;
        templateResponse: label 'ComplEtE response: %1 - %2', Comment = 'ITA="Risposta di ComplEtE: %1 - %2"';
        JsonBody: JsonObject;
        payload: Text;
        format: Text;
        MatchEmbedded: Codeunit "GPT EmbeddingMatcher";
    begin
        payload := StrSubstNo('{"input":"%1"}', UserQuestion);//'generami la risposta identificando: il testo a capo con <BR>,cambio paragrafo con <BR><BR>,voce di elenco puntato con <BR>,il grassetto con <b>');
        // Add the payload to the content
        content.WriteFrom(payload);

        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('api-key', 'XXXXXXX');

        // Assigning content to request.Content will actually create a copy of the content and assign it.
        // After this line, modifying the content variable or its associated headers will not reflect in 
        // the content associated with the request message
        request.Content := content;
        request.SetRequestUri('https://XXXXXXXX.openai.azure.com/openai/deployments/embedding/embeddings?api-version=2023-05-15');
        //request.SetRequestUri('https://oai-agicbc-demo.openai.azure.com/openai/deployments/TestCopilotBC/chat/completions?api-version=2024-05-01-preview');
        request.Method := 'POST';

        client.Send(request, response);

        // Read the response content as json.
        response.Content().ReadAs(JsonResponse);

        if ((response.HttpStatusCode = 200) or (response.HttpStatusCode = 202)) then begin
            // Extract the content from the JSON response
            BobResponse := extractContent(JsonResponse);
            if Cosine then
                BobResponse := MatchEmbedded.MatchVectoritem(BobResponse);

        end
        else
            Error(JsonResponse);
    end;


    /**
     * Extracts the content from a JSON response string.
     *
     * This procedure reads a JSON response string and extracts the content from it.
     * It first parses the JSON response to get the 'choices' array, then retrieves
     * the 'message' object and its 'content'. If the content itself is a JSON string,
     * it further extracts the 'response' field from it. If the content is not a JSON
     * string, it attempts to find and extract the JSON part from the content.
     *
     * @param jsonResponse The JSON response string to extract content from.
     * @return The extracted content as a text string.
     */
    procedure extractContent(JsonString: Text): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        JEmbeddingArray: JsonArray;
        JValue: JsonValue;
        EmbeddingText: Text;
        i: Integer;
    begin
        // Parse the JSON string into a JsonObject
        if not JObject.ReadFrom(JsonString) then
            Error('Invalid JSON string.');

        // Extract the data array from the JsonObject
        if not JObject.Get('data', JToken) then
            Error('Data array not found in JSON.');

        JArray := JToken.AsArray();

        // Check if the data array has at least one element
        if JArray.Count = 0 then
            Error('Data array is empty.');

        // Extract the first element of the data array
        JArray.Get(0, JToken);
        JObject := JToken.AsObject();

        // Extract the embedding array from the first element
        if not JObject.Get('embedding', JToken) then
            Error('Embedding array not found in data element.');

        JEmbeddingArray := JToken.AsArray();

        // Initialize the EmbeddingText variable
        EmbeddingText := '[';

        // Iterate through the embedding array
        for i := 0 to JEmbeddingArray.Count - 1 do begin
            JEmbeddingArray.Get(i, JToken);
            JValue := JToken.AsValue;
            if i > 0 then
                EmbeddingText += ',';
            EmbeddingText += JValue.AsText();
        end;

        EmbeddingText += ']';

        // Return the formatted text variable
        exit(EmbeddingText);
    end;



    procedure SplitResponseIntoVectors()
    var
        ItemRec: Record Item;
        ChunkSize: Integer;
        Chunks: Array[11] of Text;
        i: Integer;
        response: Text;
        index: Text;
    begin

        ChunkSize := 2048;

        // Split the response into chunks of 2048 characters
        for i := 1 to StrLen(Response) div ChunkSize + 1 do begin
            Chunks[i] := CopyStr(Response, (i - 1) * ChunkSize + 1, ChunkSize);
        end;

        // Loop through the Item table
        if ItemRec.FindSet() then begin
            repeat
                GetAnswer(ItemRec.Description, Response, false);

                for i := 1 to StrLen(Response) div ChunkSize + 1 do begin
                    Chunks[i] := CopyStr(Response, (i - 1) * ChunkSize + 1, ChunkSize);
                end;

                // Update the fields with the corresponding chunks
                ItemRec."GPT Vector" := Chunks[1];
                ItemRec."GPT Vector 1" := Chunks[2];
                ItemRec."GPT Vector 2" := Chunks[3];
                ItemRec."GPT Vector 3" := Chunks[4];
                ItemRec."GPT Vector 4" := Chunks[5];
                ItemRec."GPT Vector 5" := Chunks[6];
                ItemRec."GPT Vector 6" := Chunks[7];
                ItemRec."GPT Vector 7" := Chunks[8];
                ItemRec."GPT Vector 8" := Chunks[9];
                ItemRec."GPT Vector 9" := Chunks[10];
                ItemRec."GPT Vector 10" := Chunks[11];

                ItemRec.Modify();
            until ItemRec.Next() = 0;
        end;
    end;



}