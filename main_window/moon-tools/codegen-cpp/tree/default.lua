--idl源文件，如果为空，则从文本框读取--
idl_source="";

--保存的路径， 如果为空则输出到文本框--
save_path="";

--命名空间，如果为空，表示没有namesapce
name_space="";

--代码生成的一些选项--
code_switch={
    weak_ref = false,
    task_container = false,
	bson = false,
}

--如何转换字符串到类的名字--
function c_class_name(str)
    return "C"..str;
end

--如何生成文件名--
function to_file_name(name)
    return to_lower_underline_case(name);
end

