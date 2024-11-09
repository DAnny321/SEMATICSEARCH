pageextension 80310 "GPT Error List Extension" extends "Error Messages"
{
    actions
    {
        addlast(Prompting)
        {
            action("GPT Assist")
            {
                Caption = 'Error Assistant';
                ToolTip = 'Assist error using Copilot';
                Image = Sparkle;
                ApplicationArea = All;

                trigger OnAction();
                var
                    AgicAssistant: Page "GPT Assistant";
                begin
                    // Sets the question and index for the AgicAssistant and runs it modally.
                    // - Rec.Question: The question to be set in the AgicAssistant.
                    // - rec.index: The index associated with the question.
                    AgicAssistant.setQuestion('Analyze this error: ' + Rec.Message, 'kb-index');
                    AgicAssistant.runmodal;
                end;
            }
        }
    }
}