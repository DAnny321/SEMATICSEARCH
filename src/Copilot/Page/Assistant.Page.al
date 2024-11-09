page 80301 "GPT Assistant"
{
    Caption = 'GPT ASSISTANT';
    PageType = PromptDialog;
    IsPreview = true;
    Extensible = false;



    layout
    {
        area(Prompt)
        {
            field(InputText; InputText)
            {
                ShowCaption = false;
                InstructionalText = 'Ask me a question about hotels.';
                MultiLine = true;
                ApplicationArea = All;
            }


        }
        area(Content)
        {
            field(ResponseText; ResponseText)
            {
                MultiLine = true;
                ApplicationArea = All;
                ShowCaption = false;
                Width = 500;

                Editable = FALSE;
                ExtendedDatatype = RichContent;
            }



        }
    }
    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Ask';
                trigger OnAction()
                begin
                    GetAnswer();
                end;
            }
        }

    }

    var
        InputText: Text;
        ResponseText: Text;
        index: Text[50];


    // This procedure retrieves an answer from the GPT BOB Response codeunit.
    // It uses the provided input text to generate a response and stores it in the response text variable.
    // Parameters:
    //   InputText: The text input for which an answer is to be generated.
    //   ResponseText: The variable where the generated response will be stored.
    //   index: An index parameter used in the response generation process.
    procedure GetAnswer()
    var

        AssistantImpl: Codeunit "GPT Semantic Request Vector";
    begin

        AssistantImpl.GetAnswer(InputText, ResponseText, true);
        // CurrPage.Close();
    end;

    /// <summary>
    /// Sets the question and index for the assistant.
    /// </summary>
    /// <param name="question">The question text to be set.</param>
    /// <param name="parindex">The index associated with the question.</param>
    procedure setQuestion(question: Text; parindex: text[50])
    begin
        InputText := question;
        index := parindex;
    end;
}