codeunit 80312 "GPT EmbeddingMatcher"
{
    /// <summary>
    /// Finds the most similar article from a list of items compared to a given item list.
    /// </summary>
    /// <param name="itemList">The list of items to compare against.</param>
    /// <param name="myitemList">The item list to find the most similar article for.</param>
    /// <returns>Returns true if the similarity between the item lists is greater than 0.3, otherwise false.</returns>
    procedure FindMostSimilarArticle(itemList: Text; myitemList: Text): Boolean
    var
        MostSimilarArticle: Text;
        HighestSimilarity: Decimal;
        CurrentSimilarity: Decimal;
        Article: Text;
        Embedding: List of [Decimal];
        itemListDecimal: List of [Decimal];
        myRequestItemListDecimal: List of [Decimal];
    begin
        // initialize  items's embedding
        InsertEmbeddingsIntoDictionary(itemList, myitemList, itemListDecimal, myRequestItemListDecimal);

        HighestSimilarity := -1;

        CurrentSimilarity := CosineSimilarity(itemListDecimal, myRequestItemListDecimal);

        if CurrentSimilarity > 0.3 then begin
            exit(true)
        end
        else
            exit(false);

    end;

    procedure splitList(itemList: Text; itemListDecimal: List of [Decimal])
    var
        TempString: Text;
        Number: Decimal;
        i: Integer;
        valueText: text;
        valueDecimal: Decimal;
    begin
        // Remove the square brackets
        TempString := DelChr(itemList, '=', '[]');

        // Split the string by commas


        foreach valueText in TempString.Split(',') do begin
            Evaluate(valueDecimal, valueText);
            itemListDecimal.Add(valueDecimal);
        end;

    end;

    procedure CosineSimilarity(Vec1: List of [Decimal]; Vec2: List of [Decimal]): Decimal
    var
        DotProduct: Decimal;
        NormVec1: Decimal;
        NormVec2: Decimal;
        i: Integer;
        math: Codeunit Math;
    begin
        DotProduct := 0;
        NormVec1 := 0;
        NormVec2 := 0;

        for i := 1 to Vec1.Count() do begin
            DotProduct += Vec1.Get(i) * Vec2.Get(i);
            NormVec1 += Vec1.Get(i) * Vec1.Get(i);
            NormVec2 += Vec2.Get(i) * Vec2.Get(i);
        end;

        NormVec1 := math.Sqrt(NormVec1);
        NormVec2 := math.Sqrt(NormVec2);

        if (NormVec1 * NormVec2) = 0 then
            exit(0);

        exit(DotProduct / (NormVec1 * NormVec2));
    end;

    procedure InsertEmbeddingsIntoDictionary(EmbeddingStr1: Text; EmbeddingStr2: Text; Embedding1: List of [Decimal]; Embedding2: List of [Decimal])
    begin
        // Convert input strings to lists of decimals
        splitList(EmbeddingStr1, Embedding1);
        splitList(EmbeddingStr2, Embedding2);
    end;

    procedure MatchVectoritem(mySearchItem: text): Text;
    var
        ItemRec: Record Item;
        ChunkSize: Integer;
        Chunks: Array[11] of Text;
        i: Integer;
        response: Text;
        index: Text;
        CosineItem: Text;
        itemVector: Text;
    begin

        if ItemRec.FindSet() then begin
            repeat
                itemVector := ItemRec."GPT Vector" + ItemRec."GPT Vector 1" + ItemRec."GPT Vector 2" + ItemRec."GPT Vector 3" + ItemRec."GPT Vector 4" + ItemRec."GPT Vector 5" + ItemRec."GPT Vector 6" + ItemRec."GPT Vector 7" + ItemRec."GPT Vector 8" + ItemRec."GPT Vector 9" + ItemRec."GPT Vector 10";
                // Loop through the Item table
                if FindMostSimilarArticle(itemVector, mySearchItem) then begin
                    CosineItem += ItemRec."No." + ' - ' + ItemRec.Description + '<br>';
                end;
            until ItemRec.Next() = 0;
        end;
        exit(CosineItem);
    end;


}