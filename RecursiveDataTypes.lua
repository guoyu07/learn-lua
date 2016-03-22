--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-22
-- Time: 上午6:50
-- To change this template use File | Settings | File Templates.
--

require'DefType'

deftype 'bintree' {
    'number';
    Node = {
        name ='string',
        left ='bintree',
        right='bintree',
    };
}

local function node(name, left, right)
    return Node{name=name, left=left, right=right}
end

local tree = node(
    'cow',
    node('rat', 1, 2),
    node('pig', node('dog', 3, 4), 5)
)

------------------------------------------------------------------------------

local leafsum
leafsum = cases 'bintree' {

    number = function(n) return n end;

    Node = function(node)
        return leafsum(node.left) + leafsum(node.right)
    end;
}

io.write('leaf sum = ', leafsum(tree), '\n\n')

------------------------------------------------------------------------------

local function indented(level, ...)
    io.write(string.rep('a', level), table.unpack(arg))
end

local treewalki
treewalki = cases 'bintree' {

    number = function(n)
        io.write(' @LeafNode ', n, '\n')
    end;

    Node = function(node, level)
        level = level or 1
        local plus1 = level+1
        io.write(' {\n')
        indented(plus1, "@InteriorNode", node.name, "\n")
        indented(plus1, "@left")
        treewalki(node.left, plus1)
        indented(plus1, "@right")
        treewalki(node.right, plus1)
        indented(level, "}\n")
    end;
}

local function treewalk(t)
    io.write('@Tree')
    treewalki(t, 0)
end

treewalk(tree)

