--如果为true则分析文件列表--
parse_files = true;

--如何生成类的名字--
function class_name(name)
    return to_big_camel_case(name);
end

--如何生成成员的名字--
function member_name(name)
    return name;
end

--如何生成数组类的名字--
function array_class_name(name)
    return class_name(name).."List";
end

--如何生成数组成员的名字--
function array_member_name(name)
    return member_name(name).."List";
end
