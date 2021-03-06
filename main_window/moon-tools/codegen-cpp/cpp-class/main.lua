require("common")
require("user")
require("codegen")

mem_text = load_from_file_or_editor(idl_source);

App.ClearScreen();

local parser = IdlParser.new();

parser:LoadSourceFromFile(mem_text:FileBase());

local lua = parser:ParseAll();

if parser:HasErrors() then
	printnl(parser:GetCertainErrors());
	return;
end

local all_idl_classes = string_to_table("{"..lua.."}");
if not all_idl_classes then return end

local save_str = "";


for _,idl_class in ipairs(all_idl_classes) do
    set_code_switch_by_hint(idl_class.hint,code_switch);
    covert_special_types(idl_class);
	update_basic_type_table_by_hint(idl_class);

	local cpp_base_codegen = CppBaseCodeGen.new(idl_class,code_switch);
	name_space = cpp_base_codegen:GetNameSpace();

    if save_path and save_path ~= "" then
        local cpp_name = FileManager.ToAbsPath(
            save_path.."/"..
            to_file_name(idl_class.name)..".cpp"            
        );

        local h_name = FileManager.ToAbsPath(
            save_path.."/"..
            to_file_name(idl_class.name)..".h"
        );
                
        App.ClearBuffer();
        code_h(idl_class);        
        
        if App.SaveBuffer(h_name) then            
            printfnl("save to %s",h_name);
        else
            printfnl("fail to save %s",h_name);
        end
        
        App.ClearBuffer();
        code_cpp(idl_class);
        
        if App.SaveBuffer(cpp_name) then
            printfnl("save to %s",cpp_name);
        else
            printfnl("fail to save %s",cpp_name);
        end

    else
        code_h(idl_class);
        printnl("");
        code_cpp(idl_class);
    end    
end


