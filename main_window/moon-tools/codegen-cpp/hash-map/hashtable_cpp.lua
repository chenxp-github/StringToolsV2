function code_cpp(names)
	printfnl("#include \"%s.h\"",to_file_name(names.class_name));
	printfnl("#include \"syslog.h\"");
	printfnl("#include \"mem_tool.h\"");
	printfnl("#include \"misc.h\"");
	printfnl("");
    maybe_printnl(g_cpp_base_codegen:Code_NameSpaceBegin());
	printfnl("");
	printfnl("%s::%s()",names.c_entry_class_name,names.c_entry_class_name);
	printfnl("{");
	maybe_printnl(g_cpp_base_codegen:Code_InitBasic());  	
	printfnl("    m_RawPtr = NULL;");
	printfnl("    next = NULL;");
	printfnl("}");
	printfnl("");
	printfnl("%s::~%s()",names.c_entry_class_name,names.c_entry_class_name);
	printfnl("{");
	maybe_printnl(g_cpp_base_codegen:Code_Destroy());  	
	printfnl("    DEL(m_RawPtr);");
	printfnl("    next = NULL;");
	printfnl("}");
	printfnl("    ");
	printfnl("%s* %s::get()",names.c_node_class_name,names.c_entry_class_name);
	printfnl("{");
	printfnl("    return m_RawPtr;");
	printfnl("}");
	printfnl("");
	printfnl("status_t %s::set(%s *node)",names.c_entry_class_name,names.c_node_class_name);
	printfnl("{");
	printfnl("    ASSERT(m_RawPtr == NULL);");
	printfnl("    m_RawPtr = node;");
	printfnl("    return OK;");
	printfnl("}");
	printfnl("");
	printfnl("/*********************************************/");
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
    maybe_printnl(g_cpp_base_codegen:Code_InitBasic());    
	maybe_printnl(g_cpp_base_codegen:Code_BeginMarker("InitBasic"));
	maybe_printnl(g_cpp_base_codegen:Code_EndMarker("InitBasic"));	
	
	printfnl("    this->m_Capacity = 0;");
	printfnl("    this->m_Data = 0;");
	printfnl("    this->m_Size = 0;");
	printfnl("    return OK;");
	printfnl("}");
	
    printfnl("status_t %s::Init(%sint capacity)",
        names.c_class_name,
        g_cpp_base_codegen:Code_InitParam({add_comma=true})
    );
    
	printfnl("{");
	printfnl("    this->InitBasic();");
	maybe_printnl(g_cpp_base_codegen:Code_Init())    
	maybe_printnl(g_cpp_base_codegen:Code_BeginMarker("Init"));
	maybe_printnl(g_cpp_base_codegen:Code_EndMarker("Init"));	
	printfnl("    this->m_Capacity = capacity;");
	printfnl("    MALLOC(this->m_Data,%s*,capacity);",names.c_entry_class_name);
	printfnl("    memset(this->m_Data,0,capacity*sizeof(%s*));",names.c_entry_class_name);
	printfnl("    return OK;");
	printfnl("}");
	printfnl("status_t %s::Destroy()",names.c_class_name);
	printfnl("{");
 
	printfnl("    int i;");
	printfnl("    %s *q,*p;",names.c_entry_class_name);
	printfnl("");	

	maybe_printnl(g_cpp_base_codegen:Code_Destroy());  		
	maybe_printnl(g_cpp_base_codegen:Code_BeginMarker("Destroy"));
	maybe_printnl(g_cpp_base_codegen:Code_EndMarker("Destroy"));	    
	
	printfnl("    if(this->m_Data == NULL)");
	printfnl("        return OK;");
	printfnl("");
	printfnl("    for(i = 0; i < this->m_Capacity; i++)");
	printfnl("    {");
	printfnl("        p  = this->m_Data[i];");
	printfnl("        while(p)");
	printfnl("        {");
	printfnl("            q = p->next;");
	printfnl("            DEL(p);");
	printfnl("            p = q;            ");
	printfnl("        }            ");
	printfnl("    }");
	printfnl("    FREE(this->m_Data);");
	printfnl("    this->InitBasic();");
	printfnl("    return OK;");
	printfnl("}");
	printfnl("");
	printfnl("status_t %s::PutPtr(%s *ptr)",names.c_class_name,names.c_node_class_name);
	printfnl("{");
	printfnl("    int code;");
	printfnl("    %s *p;",names.c_entry_class_name);
	printfnl("");
	printfnl("    ASSERT(ptr);");
	printfnl("");
	printfnl("    if(this->Get(ptr) != NULL)");
	printfnl("        return ERROR;");
	printfnl("");
	printfnl("    code = this->HashCode(ptr);");
	printfnl("    ASSERT(code >= 0 && code < this->m_Capacity);");
	printfnl("    p = this->m_Data[code];");
	printfnl("");
	printfnl("    %s *ptr_entry;",names.c_entry_class_name);
	printfnl("    NEW(ptr_entry,%s);",names.c_entry_class_name);
	printfnl("    ptr_entry->set(ptr);");
	printfnl("");
	printfnl("    if (p == NULL)");
	printfnl("    {");
	printfnl("        this->m_Data[code] = ptr_entry;");
	printfnl("        ptr_entry->next = NULL;");
	printfnl("    }");
	printfnl("    else");
	printfnl("    {");
	printfnl("        while(p->next)");
	printfnl("        {");
	printfnl("            p = p->next;");
	printfnl("        }");
	printfnl("        p->next = ptr_entry;");
	printfnl("        ptr_entry->next = NULL;");
	printfnl("    }");
	printfnl("    this->m_Size++;");
	printfnl("    return OK;");
	printfnl("}");
	printfnl("");
	printfnl("status_t %s::Put(%s *hashentry)",names.c_class_name,names.c_node_class_name);
	printfnl("{");
	printfnl("    %s *tmp = this->CloneNode(hashentry);",names.c_node_class_name);
	printfnl("    if(!this->PutPtr(tmp))");
	printfnl("    {");
	printfnl("        DEL(tmp);");
	printfnl("        return ERROR;");
	printfnl("    }");
	printfnl("    return OK;");
	printfnl("}");
	printfnl("");
	printfnl("%s* %s::Get(%s *key)",names.c_node_class_name,names.c_class_name,names.c_node_class_name);
	printfnl("{");
	printfnl("    int code;");
	printfnl("    %s *p;",names.c_entry_class_name);
	printfnl("");
	printfnl("    ASSERT(key);");
	printfnl("");
	printfnl("    code = this->HashCode(key);");
	printfnl("    ASSERT(code >= 0 && code < this->m_Capacity);");
	printfnl("    p = this->m_Data[code];");
	printfnl("    while(p)");
	printfnl("    {");
	printfnl("        if(this->Equals(p->get(),key))");
	printfnl("            return p->get();");
	printfnl("        p = p->next;");
	printfnl("    }");
	printfnl("    return NULL;");
	printfnl("}");
	printfnl("");
	printfnl("status_t %s::EnumAll(CClosure *closure)",names.c_class_name);
	printfnl("{");
	printfnl("    int i,_contine;");
	printfnl("    %s *pre,*p,*next;",names.c_entry_class_name);
	printfnl("    ");
	printfnl("    ASSERT(closure);");
	printfnl("    ");
	printfnl("    for(i = 0; i < this->m_Capacity; i++)");
	printfnl("    {");
	printfnl("        p = this->m_Data[i];");
	printfnl("        if(p == NULL)continue;");
	printfnl("        ");
	printfnl("        pre = p;");
	printfnl("        p = p->next;");
	printfnl("        while(p)");
	printfnl("        {            ");
	printfnl("            next = p->next;");
	printfnl("            closure->SetParamPointer(0,p->get());");
	printfnl("            closure->SetParamInt(1,p==m_Data[i]); //is first");
	printfnl("            _contine = closure->Run();");
	printfnl("            //mark param 0 to NULL mean to delete the entry");
	printfnl("            if(closure->GetParamPointer(0) == NULL) ");
	printfnl("            {");
	printfnl("                p->m_RawPtr = NULL;");
	printfnl("                DEL(p);");
	printfnl("                pre->next = next;");
	printfnl("                p = next;");
	printfnl("                this->m_Size --;");
	printfnl("            }");
	printfnl("            else");
	printfnl("            {");
	printfnl("                pre = p;");
	printfnl("                p = next;");
	printfnl("            }");
	printfnl("            ");
	printfnl("            if(!_contine)");
	printfnl("                goto end;");
	printfnl("        }");
	printfnl("        ");
	printfnl("        p = this->m_Data[i];");
	printfnl("        next = p->next;");
	printfnl("        closure->SetParamPointer(0,p->get());");
	printfnl("        closure->SetParamInt(1,p==m_Data[i]);");
	printfnl("        _contine = closure->Run();");
	printfnl("        if(closure->GetParamPointer(0) == NULL)");
	printfnl("        {");
	printfnl("            p->m_RawPtr = NULL;");
	printfnl("            DEL(p);");	
	printfnl("            this->m_Data[i] = next;");
	printfnl("            this->m_Size --;");
	printfnl("        }");
	printfnl("        if(!_contine)");
	printfnl("            goto end;");
	printfnl("    }");
	printfnl("    ");
	printfnl("end:");
	printfnl("    return OK;");
	printfnl("}");
	printfnl("");
	printfnl("%s* %s::Remove(%s *key)",names.c_entry_class_name,names.c_class_name,names.c_node_class_name);
	printfnl("{");
	printfnl("    int code;");
	printfnl("    %s *pre,*p;",names.c_entry_class_name);
	printfnl("");
	printfnl("    ASSERT(key);");
	printfnl("    code = this->HashCode(key);");
	printfnl("    if(code < 0 || code >= this->m_Capacity)");
	printfnl("        return NULL;");
	printfnl("    p = this->m_Data[code];");
	printfnl("    if(p == NULL) return NULL;");
	printfnl("");
	printfnl("    if(this->Equals(p->get(),key))");
	printfnl("    {");
	printfnl("        this->m_Data[code] = p->next;");
	printfnl("        this->m_Size --;");
	printfnl("        return p;");
	printfnl("    }");
	printfnl("    else");
	printfnl("    {");
	printfnl("        while(p)");
	printfnl("        {");
	printfnl("            pre = p;");
	printfnl("            p = p->next;");
	printfnl("            if(p && this->Equals(p->get(),key))");
	printfnl("            {");
	printfnl("                pre->next = p->next;");
	printfnl("                this->m_Size --;");
	printfnl("                return p;");
	printfnl("            }");
	printfnl("        }");
	printfnl("    }");
	printfnl("");
	printfnl("    return NULL;");
	printfnl("}");
	printfnl("status_t %s::Del(%s *key)",names.c_class_name,names.c_node_class_name);
	printfnl("{");
	printfnl("    %s *p = this->Remove(key);",names.c_entry_class_name);
	printfnl("    if(p != NULL)");
	printfnl("    {");
	printfnl("        DEL(p);");
	printfnl("        return OK;");
	printfnl("    }");
	printfnl("    return ERROR;");
	printfnl("}");
	printfnl("int %s::GetSize()",names.c_class_name);
	printfnl("{");
	printfnl("    return this->m_Size;");
	printfnl("}");
	printfnl("int %s::GetCapacity()",names.c_class_name);
	printfnl("{");
	printfnl("    return this->m_Capacity;");
	printfnl("}");
	printfnl("bool %s::IsEmpty()",names.c_class_name);
	printfnl("{");
	printfnl("    return this->GetSize() <= 0;");
	printfnl("}");
	printfnl("status_t %s::DiscardAll()",names.c_class_name);
	printfnl("{");
	printfnl("    m_Data = NULL;");
	printfnl("    return OK;");
	printfnl("}");
	printfnl("int %s::HashCode(%s *hashentry)",names.c_class_name,names.c_node_class_name);
	printfnl("{");
	printfnl("    return HashCode(hashentry,m_Capacity);");
	printfnl("}");
	printfnl("");
	printfnl("status_t %s::Clear()",names.c_class_name);
	printfnl("{");
	printfnl("    int capacity = m_Capacity;");
	printfnl("    this->Destroy();");
	printfnl("    this->Init(capacity);");
	printfnl("    return OK;");
	printfnl("}");
	printfnl("");
	printfnl("status_t %s::Copy(%s *p)",names.c_class_name,names.c_class_name);
	printfnl("{");
	printfnl("    ASSERT(p);");
	maybe_printnl(g_cpp_base_codegen:Code_BeginMarker("Copy"));
	maybe_printnl(g_cpp_base_codegen:Code_EndMarker("Copy"));		
	printfnl("    this->Destroy();");
	printfnl("    this->Init(p->GetCapacity());");
	printfnl("");
	printfnl("    BEGIN_CLOSURE(on_copy)");
	printfnl("    {");
	printfnl("        CLOSURE_PARAM_PTR(%s*,self,10);",names.c_class_name);
	printfnl("        CLOSURE_PARAM_PTR(%s*,node,0);",names.c_node_class_name);
	printfnl("        self->Put(node);");
	printfnl("        return OK;");
	printfnl("    }");
	printfnl("    END_CLOSURE(on_copy);");
	printfnl("    ");
	printfnl("    on_copy.SetParamPointer(10,this);");
	printfnl("    p->EnumAll(&on_copy);");
	printfnl("    return OK;");
	printfnl("}");
	printfnl("");
	printfnl("status_t %s::Comp(%s *p)",names.c_class_name,names.c_class_name);
	printfnl("{");
	printfnl("    ASSERT(p);");
	printfnl("    if(p == this)");
	printfnl("        return 0;");
	printfnl("    ASSERT(0);");
	printfnl("    return 0;");
	printfnl("}");
	printfnl("");
	printfnl("status_t %s::Print(CFileBase *_buf)",names.c_class_name);
	printfnl("{");
	printfnl("    int i;");
	printfnl("    int collision = 0;");
	printfnl("    int maxLength = 0;");
	printfnl("");
	printfnl("    for(i = 0; i < this->m_Capacity; i++)");
	printfnl("    {");
	printfnl("        %s *p = this->m_Data[i];",names.c_entry_class_name);
	printfnl("        if(p != NULL)");
	printfnl("        {");
	printfnl("            _buf->Log(\"[%%d]->\",i);");
	printfnl("            int len = 0;");
	printfnl("            collision--;");
	printfnl("            while(p)");
	printfnl("            {");
	printfnl("                if(p->get())");
	printfnl("                {");
	printfnl("                    p->get()->Print(_buf);");
	printfnl("                }");
	printfnl("                _buf->Log(\"->\");");
	printfnl("                p = p->next;");
	printfnl("                len ++;");
	printfnl("                collision++;");
	printfnl("            }");
	printfnl("            if(len > maxLength)");
	printfnl("                maxLength = len;");
	printfnl("            _buf->Log(\"\");");
	printfnl("        }");
	printfnl("    }");
	printfnl("");
	printfnl("    _buf->Log(\"capacity is %%d\", m_Capacity);");
	printfnl("    _buf->Log(\"total size is %%d\",m_Size);");
	printfnl("    _buf->Log(\"maximum linked list length is %%d\",maxLength);");
	printfnl("    _buf->Log(\"total collison is %%d\",collision);");
	printfnl("");
	maybe_printnl(g_cpp_base_codegen:Code_BeginMarker("Print"));
	maybe_printnl(g_cpp_base_codegen:Code_EndMarker("Print"));		
	printfnl("");
	printfnl("    return OK;");
	printfnl("}");
	printfnl("");
	printfnl("status_t %s::ToArray(%s *arr[], int *len)",names.c_class_name,names.c_node_class_name);
	printfnl("{    ");
	printfnl("    ASSERT(arr && len);   ");
	printfnl("    int max_len = *len;    ");
	printfnl("    *len = 0;    ");
	printfnl("       ");
	printfnl("    BEGIN_CLOSURE(on_enum)        ");
	printfnl("    {        ");
	printfnl("        CLOSURE_PARAM_PTR(%s*,node,0);        ",names.c_node_class_name);
	printfnl("        CLOSURE_PARAM_PTR(%s*,self,10);        ",names.c_class_name);
	printfnl("        CLOSURE_PARAM_PTR(%s**,arr,11);        ",names.c_node_class_name);
	printfnl("        CLOSURE_PARAM_PTR(int*,len,12);        ");
	printfnl("        CLOSURE_PARAM_INT(max_len,13);        ");
	printfnl("        ASSERT(*len < max_len);        ");
	printfnl("        arr[(*len)++] = node;           ");
	printfnl("        return OK;        ");
	printfnl("    }    ");
	printfnl("    END_CLOSURE(on_enum);");
	printfnl("            ");
	printfnl("    on_enum.SetParamPointer(10,this);    ");
	printfnl("    on_enum.SetParamPointer(11,arr);    ");
	printfnl("    on_enum.SetParamPointer(12,len);    ");
	printfnl("    on_enum.SetParamInt(13,max_len);        ");
	printfnl("    this->EnumAll(&on_enum);    ");
	printfnl("    return OK;");
	printfnl("}");

	printfnl("");
	printfnl("/*********************************************/");
	printfnl("/*********************************************/");
	printfnl("int %s::HashCode(%s *hashentry,int capacity)",names.c_class_name,names.c_node_class_name);
	printfnl("{");
	printfnl("    ASSERT(hashentry);");
	printfnl("    ASSERT(0);");
	printfnl("    return 0;");
	printfnl("}");
	printfnl("");
	printfnl("bool %s::Equals(%s *hashentry1, %s *hashentry2)",names.c_class_name,names.c_node_class_name,names.c_node_class_name);
	printfnl("{");
	printfnl("    ASSERT(hashentry1 && hashentry2);");
	printfnl("    return hashentry1->Comp(hashentry2) == 0;");
	printfnl("}");
	printfnl("");
	printfnl("%s* %s::CloneNode(%s *hashentry)",names.c_node_class_name,names.c_class_name,names.c_node_class_name);
	printfnl("{");
	printfnl("    %s *ptr;",names.c_node_class_name);
	printfnl("    NEW(ptr,%s);",names.c_node_class_name);
	printfnl("    ptr->Init();");
	printfnl("    ptr->Copy(hashentry);");
	printfnl("    return ptr;");
	printfnl("}");
	printfnl("");

    maybe_printnl(g_cpp_base_codegen:Code_NameSpaceEnd());

end