#include "ruby.h"
#include "vm_core.h"

static VALUE hello_world(VALUE mod)
{
  return rb_str_new2("hello world");
}

static VALUE tco_compile(VALUE mod, VALUE src)
{
  VALUE retval;
  if(rb_iseq_compile_with_option) {
    retval = Qtrue;
  } else {
    retval = Qfalse;
  }
  return retval;
}

void Init_tco_method()
{
  VALUE mTCOMethod = rb_define_module("TCOMethod");
  rb_define_singleton_method(mTCOMethod, "hello_world", hello_world, 0);
  rb_define_singleton_method(mTCOMethod, "tco_compile", tco_compile, 0);
}
