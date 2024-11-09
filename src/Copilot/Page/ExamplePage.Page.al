page 80305 "GPT Example Page"
{
    PageType = List;
    ApplicationArea = All;
    Caption = 'Example Page';
    UsageCategory = Lists;



    actions
    {
        area(processing)
        {
            action(Copilot)
            {
                ApplicationArea = All;
                Caption = 'Ask to Copilot';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Sparkle;

                trigger OnAction()
                var
                    AgicAssistant: Page "GPT Assistant";
                begin

                    AgicAssistant.runmodal;

                end;
            }

            action(itemVectorSetup)
            {
                ApplicationArea = All;
                Caption = 'Setup Item Vector';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Sparkle;

                /// <summary>
                /// Triggered when the action is executed. This trigger calls the SplitResponseIntoVectors method
                /// from the "GPT Semantic Request Vector" codeunit and displays a message indicating the job is done.
                /// </summary>
                trigger OnAction()
                var
                    semanticVector: Codeunit "GPT Semantic Request Vector";
                begin

                    semanticVector.SplitResponseIntoVectors();
                    message('Job Done');

                end;
            }

        }
    }


}