require("common")

function code_basic_cpp(names)

    printfnl("#include \"%s.h\"",names.file_name);
    printfnl("#include \"mem_tool.h\"");
    printfnl("#include \"syslog.h\"");
    printfnl("");
    printnl(g_cpp_base_codegen:Code_NameSpaceBegin());
    printfnl("");
    printfnl("%s::%s()",names.c_class_name,names.c_class_name);
    printfnl("{");
    printfnl("    this->InitBasic();");
    printfnl("}");
    printfnl("%s::~%s()",names.c_class_name,names.c_class_name);
    printfnl("{");
    printfnl("    this->Destroy();");
    printfnl("}");
    printfnl("status_t %s::InitBasic()",names.c_class_name);
    printfnl("{");

    printnl(g_cpp_base_codegen:Code_InitBasic());    

    printfnl("    this->m_Data = NULL;");
    printfnl("    this->m_Top = 0;");
    printfnl("    this->m_Size = 0;        ");
    printfnl("    return OK;");
    printfnl("}");

    printfnl("status_t %s::Init(%sint init_size)",
        names.c_class_name,
        g_cpp_base_codegen:Code_InitParam({add_comma=true})
    ); 

    printfnl("{");
    printfnl("    this->InitBasic();");
    
    printnl(g_cpp_base_codegen:Code_Init());    

    printfnl("    MALLOC(this->m_Data,%s,init_size);",names.node_class_name);
    printfnl("    this->m_Size = init_size;");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("status_t %s::Destroy()",names.c_class_name);
    printfnl("{");
	printfnl(g_cpp_base_codegen:Code_Destroy());
    printfnl("    FREE(this->m_Data);");
    printfnl("    this->InitBasic();");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("bool %s::IsEmpty()",names.c_class_name);
    printfnl("{");
    printfnl("    return this->m_Top <= 0;");
    printfnl("}");
    printfnl("bool %s::IsFull()",names.c_class_name);
    printfnl("{");
    printfnl("    return this->m_Top >= this->m_Size;");
    printfnl("}");
    printfnl("int %s::GetLen()",names.c_class_name);
    printfnl("{");
    printfnl("    return this->m_Top;");
    printfnl("}");
    printfnl("status_t %s::Clear()",names.c_class_name);
    printfnl("{    ");
    printfnl("    this->m_Top = 0;");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("status_t %s::AutoResize()",names.c_class_name);
    printfnl("{");
    printfnl("    if(this->IsFull())");
    printfnl("    {");
    printfnl("        REALLOC(this->m_Data,%s,this->m_Size,this->m_Size * 2);",names.node_class_name);
    printfnl("        this->m_Size *= 2;");
    printfnl("    }");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("");
    printfnl("status_t %s::Push(%s node)",names.c_class_name,names.node_class_name);
    printfnl("{    ");
    printfnl("    this->AutoResize();");
    printfnl("    ASSERT(!this->IsFull());");
    printfnl("    this->m_Data[this->m_Top]= node;");
    printfnl("    this->m_Top ++;    ");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("");
    printfnl("%s %s::Pop()",names.node_class_name,names.c_class_name);
    printfnl("{");
    printfnl("    ASSERT(!this->IsEmpty());");
    printfnl("    this->m_Top --;");
    printfnl("    return this->m_Data[this->m_Top];");
    printfnl("}");
    printfnl("");
    printfnl("%s %s::GetElem(int index)",names.node_class_name,names.c_class_name);
    printfnl("{");
    printfnl("    ASSERT(index >= 0 && index < this->m_Top);");
    printfnl("    return this->m_Data[index];");
    printfnl("}");
    printfnl("");
    printfnl("int %s::BSearchPos(%s node, int order, int *find_flag)",names.c_class_name,names.node_class_name);
    printfnl("{");
    printfnl("    int low,high,mid;");
    printfnl("    int comp;");
    printfnl("");
    printfnl("    low = 0; high=this->GetLen() - 1;");
    printfnl("    while(low<=high)");
    printfnl("    {");
    printfnl("        mid = (low+high) >> 1;");
    printfnl("        comp = this->CompNode(this->m_Data[mid],node);");
    printfnl("        if(comp == 0)");
    printfnl("        {");
    printfnl("            *find_flag = TRUE;");
    printfnl("            return mid;");
    printfnl("        }");
    printfnl("");
    printfnl("        if(order != 0) comp = -comp;");
    printfnl("        if(comp>0)high=mid-1;else low=mid+1;");
    printfnl("    }");
    printfnl("    *find_flag = FALSE;");
    printfnl("    return low;");
    printfnl("}");
    printfnl("status_t %s::InsElem(int index, %s node)",names.c_class_name,names.node_class_name);
    printfnl("{");
    printfnl("    int k;");
    printfnl("    ASSERT(index >= 0 && index <= this->m_Top);    ");
    printfnl("    this->AutoResize();");
    printfnl("    ASSERT(!this->IsFull());");
    printfnl("    for(k = this->m_Top; k > index; k--)");
    printfnl("    {");
    printfnl("        this->m_Data[k] = this->m_Data[k - 1];");
    printfnl("    }");
    printfnl("    this->m_Data[index] = node;");
    printfnl("    this->m_Top++;");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("status_t %s::DelElem(int index)",names.c_class_name);
    printfnl("{");
    printfnl("    int k;");
    printfnl("    ASSERT(index >= 0 && index < this->m_Top);");
    printfnl("    for(k = index; k < this->m_Top-1; k++)");
    printfnl("    {");
    printfnl("        this->m_Data[k] = this->m_Data[k + 1];");
    printfnl("    }");
    printfnl("    this->m_Top --;");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("status_t %s::InsOrdered(%s node, int order, int unique)",names.c_class_name,names.node_class_name);
    printfnl("{");
    printfnl("    int pos,find;");
    printfnl("    ");
    printfnl("    pos = this->BSearchPos(node,order,&find);");
    printfnl("    if(find && unique)");
    printfnl("        return ERROR;");
    printfnl("    ");
    printfnl("    return this->InsElem(pos,node);");
    printfnl("}");
    printfnl("int %s::SearchPos(%s node)",names.c_class_name,names.node_class_name);
    printfnl("{");
    printfnl("    int i;");
    printfnl("    for(i=0;i<this->m_Top;i++)");
    printfnl("    {");
    printfnl("        if(this->CompNode(this->m_Data[i],node) == 0)");
    printfnl("            return i;");
    printfnl("    }");
    printfnl("    return -1;");
    printfnl("}");
    printfnl("%s %s::GetTop()",names.node_class_name,names.c_class_name);
    printfnl("{");
    printfnl("    ASSERT(!this->IsEmpty());");
    printfnl("    return this->m_Data[this->m_Top - 1];");
    printfnl("}");
    printfnl("status_t %s::SetElem(int index, %s node)",names.c_class_name,names.node_class_name);
    printfnl("{");
    printfnl("    ASSERT(index >= 0 && index < this->m_Top);");
    printfnl("    this->m_Data[index] = node;");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("status_t %s::Sort(int order)",names.c_class_name);
    printfnl("{");
    printfnl("    int i;");
    printfnl("    %s tmp;",names.c_class_name);
    printfnl("");
	
	if code_switch.task_container then
		printfnl("    tmp.Init(GetTaskMgr(),this->GetLen());");
	else
		printfnl("    tmp.Init(this->GetLen());");
	end	
	
    printfnl("    for(i = 0; i < this->GetLen(); i++)");
    printfnl("    {");
    printfnl("        tmp.Push(this->GetElem(i));");
    printfnl("    }");
    printfnl("    ");
    printfnl("    this->m_Top = 0;");
    printfnl("    for(i = 0; i < tmp.GetLen(); i++)");
    printfnl("    {");
    printfnl("        this->InsOrdered(tmp.GetElem(i),order,0);");
    printfnl("    }");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("");
    printfnl("int %s::Comp(%s *stk)",names.c_class_name,names.c_class_name);
    printfnl("{");
    printfnl("    ASSERT(stk);");
    printfnl("    if(this == stk)");
    printfnl("        return 0;");
    printfnl("    ASSERT(0);");
    printfnl("    return 0;");
    printfnl("}");
    printfnl("");
    printfnl("status_t %s::Copy(%s *_p)",names.c_class_name,names.c_class_name);
    printfnl("{");
    printfnl("    int i;");
    printfnl("    ASSERT(_p);");

	if code_switch.task_container then
		printfnl("    CTaskMgr *taskmgr = this->GetTaskMgr();");
	end
	
    printfnl("    this->Destroy();");

	if code_switch.task_container then
		printfnl("    this->Init(taskmgr);");
	else
		printfnl("    this->Init();");
	end

    printfnl("    for(i = 0; i < _p->GetLen(); i++)");
    printfnl("    {");
    printfnl("        this->Push(_p->GetElem(i));");
    printfnl("    }");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("");

if code_switch.bson then        
    printfnl("status_t %s::SaveBson(CMiniBson *_bson)",names.c_class_name);
    printfnl("{");
    printfnl("    ASSERT(_bson);");
    printfnl("    ");
    printfnl("    fsize_t off;");
    printfnl("    _bson->StartArray(\"_array_\",&off);");
    printfnl("    char name[256];");
    printfnl("    for(int i = 0; i < this->GetLen(); i++)");
    printfnl("    {           ");
    printfnl("        sprintf(name,\"%%d\",i);");
    printfnl("        _bson->PutDouble(name,this->GetElem(i));     ");
    printfnl("    }");
    printfnl("    _bson->EndArray(off,this->GetLen());    ");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("");
    printfnl("status_t %s::SaveBson(CMem *_mem)",names.c_class_name);
    printfnl("{");
    printfnl("    ASSERT(_mem);");
    printfnl("    CMiniBson _bson;");
    printfnl("    _bson.Init();");
    printfnl("    _bson.SetRawBuf(_mem);");
    printfnl("    _bson.StartDocument();");
    printfnl("    this->SaveBson(&_bson);");
    printfnl("    _bson.EndDocument();");
    printfnl("    _mem->SetSize(_bson.GetDocumentSize());");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("");
    printfnl("status_t %s::LoadBson(CMiniBson *_bson)",names.c_class_name);
    printfnl("{");
    printfnl("    ASSERT(_bson);");
    printfnl("    ");
    printfnl("    CMiniBson doc;");
    printfnl("    doc.Init();");
    printfnl("    ");
    printfnl("    int len = 0;");
    printfnl("    BSON_CHECK(_bson->GetArray(\"_array_\",&doc,&len));");
    printfnl("    this->Clear();");
    printfnl("    ");
    printfnl("    doc.ResetPointer();");
    printfnl("    for(int i = 0; i < len; i++)");
    printfnl("    {");
    printfnl("        %s t = 0;",names.node_class_name);
    printfnl("        _bson->GetDouble(NULL,&t);");
    printfnl("        this->Push(t);");
    printfnl("    }");
    printfnl("    ");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("status_t %s::LoadBson(CFileBase *_file)",names.c_class_name);
    printfnl("{");
    printfnl("    ASSERT(_file);");
    printfnl("    CMiniBson _bson;");
    printfnl("    _bson.Init();");
    printfnl("    _bson.LoadBson(_file);");
    printfnl("    _bson.ResetPointer();");
    printfnl("    return this->LoadBson(&_bson);");
    printfnl("}");
    printfnl("");
end

    printfnl("/***************************************************/");
    printfnl("status_t %s::Print(CFileBase *_buf)",names.c_class_name);
    printfnl("{");
    printfnl("    return OK;");
    printfnl("}");
    printfnl("");
    printfnl("int %s::CompNode(%s node1, %s node2)",names.c_class_name,names.node_class_name,names.node_class_name);
    printfnl("{");
    printfnl("    if(node1 > node2) return 1;");
    printfnl("    if(node1 < node2) return -1;");
    printfnl("    return 0;");
    printfnl("}");
    printfnl("/***************************************************/");
    printnl("");
    printnl(g_cpp_base_codegen:Code_NameSpaceEnd());
end