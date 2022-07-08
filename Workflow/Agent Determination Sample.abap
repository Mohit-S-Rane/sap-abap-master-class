FUNCTION zf_wf_determina_responsaveis.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      AC_CONTAINER STRUCTURE  SWCONT
*"      ACTOR_TAB STRUCTURE  SWHACTOR
*"  EXCEPTIONS
*"      NOBODY_FOUND
*"----------------------------------------------------------------------
  INCLUDE <cntn01>.

  DATA:
    lv_usuario LIKE sy-uname.

  swc_get_element ac_container 'USUARIO' lv_usuario.
  IF lv_usuario IS INITIAL.
    RAISE nobody_found.
  ENDIF.

  actor_tab-otype = 'US'.
  actor_tab-objid = lv_usuario.
  APPEND actor_tab.

ENDFUNCTION.