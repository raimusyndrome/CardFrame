require "CSV"

class CardData
    attr_reader :printNum, :rarity, :cost

    module ColNo
        COST = 2

        NAME = 24
        SPTYPE = 6
        TYPE = 7
        SUBTYPE = 8
        TEXT = 26

        COLOR = 5
        POWER = 10
        TOUGHNESS = 11
        LOYALTY = 12

        REV_NAME = 32 
        REV_SPTYPE = 16
        REV_TYPE = 17
        REV_SUBTYPE = 18
        REV_TEXT = 34
        REV_COLOR = 15
        REV_POWER = 20
        REV_TOUGHNESS = 21
        REV_LOYALTY = 22

        EN_NAME = 23
        EN_TEXT = 25

        CARDNO = 30
        CARDSET = 40
        RARITY = 41

        PRINTNUM = 44
    end

    def initialize
        @face = Side.new(SideType::FACE)
        @back = Side.new(SideType::BACK)
    end

    def set row
       @cost = row[ColNo::COST]; 
       @face.set(row);
       @back.set(row);
       @cardNo = row[ColNo::CARDNO];
       @cardSet = row[ColNo::CARDSET];
       @rarity = row[ColNo::RARITY];

       @printNum = row[ColNo::PRINTNUM];
       if @printNum.nil? then
           @printNum = 0
       end
    end

    def to_s
        str = @face.name + "\n"
        str += @face.color + " : " + @cost + "\n"
        str += @face.getType
        str += "\n"
        str += @face.getParam
        str += "\n"
        str += @face.text + "\n"
        str += @rarity + " / " + @cardSet + "\n"

        return str;
    end

    def getName
        return @face.name
    end

    def getColor
        return @face.color
    end

    def getType
        return @face.getType
    end

    def getText
        return @face.text
    end

    def getPower
        return @face.power
    end

    def getToughness
        return @face.toughness
    end

    def getLoyalty
        return @face.loyalty
    end

    module SideType
        FACE = 0
        BACK = 1
    end

    class Side
        attr_reader :name, :color, :text
        attr_reader :power, :toughness, :loyalty

        def initialize type
            @type = type
        end

        def set row
            if @type == SideType::FACE then
                getFaceData(row)
            else
                getBackData(row)
            end
        end

        def getFaceData row
            @name       = row[ColNo::NAME];
            @spType     = row[ColNo::SPTYPE]
            @type       = row[ColNo::TYPE]
            @subType    = row[ColNo::SUBTYPE]
            @text       = row[ColNo::TEXT]
            @color      = row[ColNo::COLOR]
            @power      = row[ColNo::POWER]
            @toughness  = row[ColNo::TOUGHNESS]
            @loyalty    = row[ColNo::LOYALTY]
        end

        def getBackData row
            @name = row[ColNo::REV_NAME];
        end

        def getType
            if @spType.nil? then
                str = @type
            else 
                str = @spType + @type
            end
            if !@subType.nil? then
                str += " - " + @subType
            end
            return str;
        end

        def getParam
            if @loyalty.nil? then
                str = @power.to_s + " / " + @toughness.to_s
            else
                str = @loyalty.to_s
            end
            return str;
        end

    end
end

def MTGParser file
    cardlist = Array.new;
    open( file, "r:Shift_JIS:UTF-8", undef: :replace) do |f|
    # open( file, "r", undef: :replace) do |f|
        CSV.new( f, headers: true, converters: :numeric ).each do |row|
            card = CardData.new

            card.set(row);

            cardlist << card;
        end
    end

    return cardlist
end

if __FILE__ == $0 then
    list = MTGParser "THS_BNG.csv"
    puts list[0].to_s
end

