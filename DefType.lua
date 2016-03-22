------------------------------------------------------------------------------
-- DefType.lua
------------------------------------------------------------------------------

local vnames  = {}  -- table of variants defined with deftype
local defined = {   -- table of types defined with deftype
  ['nil']      = false,
  ['boolean']  = false,
  ['number']   = false,
  ['string']   = false,
  ['table']    = false,
  ['function'] = false,
  ['userdata'] = false,
  ['thread']   = false,
}

local function check(cond, level, fmt, ...)
  if cond then return cond end
  error(string.format(fmt, unpack(arg)), level+1)
end

local function err(fmt, ...)
  error(string.format(fmt, unpack(arg)), 3)
end

local function remove_basic_types(variants)
  local basic_types = {}
  for i = 1,#variants do
    local vtype = variants[i]
    check(type(vtype)=='string', 3, 'expecting Lua type name')
    check(defined[vtype]==false, 3, 'expecting basic Lua type, not %s', vtype)
    basic_types[vtype] = 'basic'
    variants[i] = nil
  end
  return basic_types
end

function gettype(t)
  local vname = type(t)
  if vname=='table' then vname = t.__variant or vname end
  return vname
end

local function constructor(tname, vname, vtype)
  local function setvariant(t)
    local vn = type(t)
    if vn=='table' then vn = t.__variant or vn end
    if vn~='table' then error(vname ..' expecting table, not '.. vn, 3) end
    t.__variant = vname
    return t
  end

  if type(vtype)=='table' then
    for fn,ft in pairs(vtype) do
      check(type(ft)=='string', 3, 'expecting string for type name for %s', fn)
    end
    return function(v)  -- constructor for variant vname
      if type(v)~='table' then err('%s:%s expecting table', tname, vname) end
      for fn,ft in pairs(vtype) do  -- check field types
        local variants = defined[ft]
        if variants==nil then
          err('%s:%s undefined type %s for field %s', tname, vname, ft, fn)
        end
        local vn = gettype(v[fn])
        if not (variants and variants[vn] or vn==ft) then
          err('%s:%s field %s should be %s, not %s', tname, vname, fn, ft, vn)
        end
      end
      return setvariant(v)
    end
  elseif type(vtype)=='function' then
    return function(...) return setvariant(vtype(unpack(arg))) end
  end
  return setvariant{value=vtype}  -- just a value, not a function
end

-- defines a new recursive data type
function deftype(tname)
  check(type(tname)=='string', 2, 'expecting string for type name')
  check(defined[tname]==nil, 2, 'cannot redefine type %s', tname)
  check(vnames[tname]==nil, 2, 'cannot have a type named %s', tname)
  return function(variants)
    check(type(variants)=='table', 2, 'expecting table of variants')
    local basic_types = remove_basic_types(variants)
    local env = _ENV  -- will store constructors in callers environment
    for vname,vtype in pairs(variants) do -- make constructor for each variant
      check(type(vname)=='string', 2, 'expecting string for variant name')
      check(defined[vname]==nil and vname~=tname and vname~='default', 2,
            'cannot have a variant named %s', vname)
      check(vnames[vname]==nil, 2, 'cannot have two variants named %s', vname)
      check(env[vname]==nil, 2, 'cannot redefine %s', vname)
      vnames[vname] = true
      env[vname] = constructor(tname, vname, vtype)
    end
    for n,v in pairs(basic_types) do variants[n] = v end
    defined[tname] = variants  -- add to table of defined types
  end
end

local function check_cases(tname, funcs)
  check(type(funcs)=='table', 3, 'expecting table of variant functions')
  local variants = check(defined[tname], 3, 'undefined type %s', tname)
  for vname,vfunc in pairs(funcs) do  -- check variant functions
    check(type(vname)=='string', 3, 'expecting string for variant name')
    check(type(vfunc)=='function', 3, '%s is not a function', vname)
    check(variants[vname] or vname=='default', 3, 'undefined variant %s', vname)
  end
  return variants
end

-- returns a function that switches on the variant
-- each variant function should be function(variant, ...)
function cases(tname)
  check(type(tname)=='string', 2, 'expecting string for type name')
  return function(funcs)
    local variants = check_cases(tname, funcs)
    return function(v, ...) -- switch function
      local vname = gettype(v)
      if not variants[vname] then err('expecting %s, not %s', tname, vname) end
      local vf = funcs[vname] or funcs.default  -- get variant function
      if not vf then err('missing variant function for %s:%s', tname, vname) end
      return vf(v, table.unpack(arg)) -- pass variant and additional arguments
    end
  end
end


--[[

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
  io.write(string.rep('  ', level), unpack(arg))
end

local treewalki
treewalki = cases 'bintree' {

  number = function(n)
    io.write(' @LeafNode ', n, '\n')
  end;

  Node = function(node, level)
    local plus1 = level+1
    io.write(' {\n')
    indented(plus1, '@InteriorNode ', node.name, '\n')
    indented(plus1, '@left')
    treewalki(node.left, plus1)
    indented(plus1, '@right')
    treewalki(node.right, plus1)
    indented(level, '}\n')
  end;
}

local function treewalk(t)
  io.write('@Tree')
  treewalki(t, 0)
end

treewalk(tree)

--]]

--[[
leaf sum = 15

@Tree {
  @InteriorNode cow
  @left {
    @InteriorNode rat
    @left @LeafNode 1
    @right @LeafNode 2
  }
  @right {
    @InteriorNode pig
    @left {
      @InteriorNode dog
      @left @LeafNode 3
      @right @LeafNode 4
    }
    @right @LeafNode 5
  }
}
--]]
