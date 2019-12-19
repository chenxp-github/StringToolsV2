一个完整的例子，展示了能够支持的所有类型

class Test:Base{
	int a; //基本类型
	int *ptr; //指针类型
	string str; //字符串类型
	[weak] Obj *weak_ptr; //弱指针类型
	array<int> arr1; //未知大小的数组
	array<int,10> arr2; //固定大小的数组
	array<Obj> obj_arr; //对象数组
	array<string> str_arr; //字符串数组
	[optional] int opt_val1; //可选项
	[optional] Obj opt_obj1; //对象可选项
	[optional] string opt_str; //可选字符串
	array<int> *ptr_arr; //指针数组这么声明
	array<Obj> *obj_ptr_arr; //对象类型指针数组
}

可以给class加上 [NameSpace ns] 之类的hint来声明名字空间

[NameSpace ns]
class Test{
	ns1::Obj obj; //变量也是可以带命名空间的
}

可以直接通过hint使用一些选项开关，例如

[CodeSwitch bson=true,weak_ref=true,code_mark=true]
class Test{
}