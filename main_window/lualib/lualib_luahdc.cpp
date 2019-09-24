#include "lualib_luahdc.h"
#include "mem_tool.h"
#include "syslog.h"

static bool luahdc_is_userdata_valid(lua_userdata *ud)
{
    if(ud == NULL)return false;
    if(ud->p == NULL)return false;
    if(ud->__weak_ref_id == 0) return false;
    CLuaHdc *p = (CLuaHdc*)ud->p;
    return p->__weak_ref_id == ud->__weak_ref_id;
}    

bool is_luahdc(lua_State *L, int idx)
{        
    const char* ud_names[] = {
        LUA_USERDATA_LUAHDC,
    };            
    lua_userdata *ud = NULL;
    for(int i = 0; i < sizeof(ud_names)/sizeof(ud_names[0]); i++)
    {
        ud = (lua_userdata*)luaL_testudata(L, idx, ud_names[i]);
        if(ud)break;
    }
    return luahdc_is_userdata_valid(ud);  
}

CLuaHdc *get_luahdc(lua_State *L, int idx)
{
    lua_userdata *ud = NULL;
    if(is_luahdc(L,idx))
    {
        ud = (lua_userdata*)lua_touserdata(L,idx);		
    }
    ASSERT(ud);
    return (CLuaHdc *)ud->p;
} 

lua_userdata *luahdc_new_userdata(lua_State *L,CLuaHdc *pobj,int is_weak)
{
    lua_userdata *ud = (lua_userdata*)lua_newuserdata(L,sizeof(lua_userdata));
    ASSERT(ud && pobj);
    ud->p = pobj;
    ud->is_attached = is_weak;
    ud->__weak_ref_id = pobj->__weak_ref_id;
    luaL_getmetatable(L,LUA_USERDATA_LUAHDC);
    lua_setmetatable(L,-2);
    return ud;
}

static int luahdc_gc_(lua_State *L)
{
    if(!is_luahdc(L,1)) return 0;

    lua_userdata *ud = (lua_userdata*)lua_touserdata(L,1);		
    ASSERT(ud);

    if(!(ud->is_attached))
    {
        CLuaHdc *pluahdc = (CLuaHdc*)ud->p;
        DEL(pluahdc);
    }
    return 0;
}

static int luahdc_issame_(lua_State *L)
{
    CLuaHdc *pluahdc1 = get_luahdc(L,1);
    ASSERT(pluahdc1);
    CLuaHdc *pluahdc2 = get_luahdc(L,2);
    ASSERT(pluahdc2);
    int is_same = (pluahdc1==pluahdc2);
    lua_pushboolean(L,is_same);
    return 1;
}

static int luahdc_tostring_(lua_State *L)
{
    CLuaHdc *pluahdc = get_luahdc(L,1);
    char buf[1024];
    sprintf(buf,"userdata:luahdc:%p",pluahdc);
    lua_pushstring(L,buf);
    return 1;
}

/****************************************************/
static status_t luahdc_destroy(lua_State *L)
{
    CLuaHdc *pluahdc = get_luahdc(L,1);
    ASSERT(pluahdc);
    status_t ret0 = pluahdc->Destroy();
    lua_pushboolean(L,ret0);
    return 1;
}

/****************************************************/
static const luaL_Reg luahdc_funcs_[] = {
    {"__gc",luahdc_gc_},
    {"__tostring",luahdc_tostring_},
    {"__is_same",luahdc_issame_},
    {"Destroy",luahdc_destroy},
    {NULL,NULL},
};

const luaL_Reg* get_luahdc_funcs()
{
    return luahdc_funcs_;
}

static int luaL_register_luahdc(lua_State *L)
{	
    static luaL_Reg _luahdc_funcs_[MAX_LUA_FUNCS];
    int _index = 0;        

    CLuaVm::CombineLuaFuncTable(_luahdc_funcs_,&_index,get_luahdc_funcs(),true);

    luaL_newmetatable(L, LUA_USERDATA_LUAHDC);
    lua_pushvalue(L, -1);	
    lua_setfield(L, -2, "__index");	
    luaL_setfuncs(L,_luahdc_funcs_,0);	
    lua_pop(L, 1);
    luaL_newlib(L,_luahdc_funcs_);
    return 1;
}        

int luaopen_luahdc(lua_State *L)
{
    luaL_requiref(L, "Hdc",luaL_register_luahdc,1);
    lua_pop(L, 1);
    return 0;
}        

