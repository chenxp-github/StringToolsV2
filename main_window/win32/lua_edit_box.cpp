#include "lua_edit_box.h"
#include "syslog.h"
#include "mem_tool.h"
#include "globals.h"

CLuaEditBox::CLuaEditBox()
{
    this->InitBasic();
}

CLuaEditBox::~CLuaEditBox()
{
    this->Destroy();
}

status_t CLuaEditBox::InitBasic()
{
    CLuaWindowBase::InitBasic();
    return OK;
}

status_t CLuaEditBox::Init()
{
    this->InitBasic();
    CLuaWindowBase::Init();
    return OK;
}

status_t CLuaEditBox::Destroy()
{
    CLuaWindowBase::Destroy();
    this->InitBasic();
    return OK;
}

status_t CLuaEditBox::Create()
{
    GLOBAL_LUA_THREAD(lua_thread);
    ASSERT(lua_thread->IsInThisThread());
    
    BEGIN_NEW_CLOSURE(on_main_thread)
    {
        CLOSURE_PARAM_WEAKPTR(CLuaEditBox*,self,10);        
        CLOSURE_PARAM_PTR(int*,run_end,11);
        self->CreateCtrl(L"EDIT");    
        *run_end = 1;
        return OK;
    }
    END_NEW_CLOSURE(on_main_thread);
    
	CWeakPointer<CLuaEditBox> wp(this);
    on_main_thread->SetParamWeakPointer(10,&wp);    
    
    static int run_end = 0;
    run_end = 0;
    on_main_thread->SetParamPointer(11,&run_end);
    GLOBAL_MAIN_TASK_RUNNER(runner);
    runner->AddClosure(on_main_thread,0);
    
    while(!run_end && lua_thread->IsRunning())
    {
        crt_msleep(10);
    }
    return OK;
}

status_t CLuaEditBox::SetMaxText(int max)
{
    return ::SendMessageW(hwnd,EM_SETLIMITTEXT,(WPARAM)max,0);
}

status_t CLuaEditBox::SetSel(int s, int e)
{
    return ::SendMessageW(hwnd,EM_SETSEL,(WPARAM)s,(LPARAM)e);
}

