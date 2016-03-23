--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-23
-- Time: 下午9:34
-- To change this template use File | Settings | File Templates.
--


function setvar(Table, Name, Value)

    if type(Table) ~= 'table' then
        Table,Name,Value = _G,Table,Name
    end

    local Concat, Key = false, ''

    string.gsub(Name, '([^%.]+)(%.*)',
     function(Word,Delimiter)
         if Delimiter == '.' then
             if Concat then
                 Word = Key .. Word
                 Concat,Key = false,''
             end
             if type(Table[Word]) ~= 'table' then
                 Table[Word] = {}
             end
             Table = Table[Word]
         else
              Key = Key .. Word .. Delimiter
              Concat = true
         end
     end
    )
    if Key == '' then
        table.insert(Table,Value)
    else
         Table[Key] = Value
    end
end


