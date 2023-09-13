##########################################################################################
#
# Magisk模块安装脚本
#
##########################################################################################
##########################################################################################
#
# 使用说明:
#
# 1. 将文件放入系统文件夹(删除placeholder文件)
# 2. 在module.prop中填写您的模块信息
# 3. 在此文件中配置和调整
# 4. 如果需要开机执行脚本，请将其添加到post-fs-data.sh或service.sh
# 5. 将其他或修改的系统属性添加到system.prop
#
##########################################################################################
##########################################################################################
#
# 安装框架将导出一些变量和函数。
# 您应该使用这些变量和函数来进行安装。
#
# !请不要使用任何Magisk的内部路径，因为它们不是公共API。
# !请不要在util_functions.sh中使用其他函数，因为它们也不是公共API。
# !不能保证非公共API在版本之间保持兼容性。
#
# 可用变量:
#
# MAGISK_VER (string):当前已安装Magisk的版本的字符串(字符串形式的Magisk版本)
# MAGISK_VER_CODE (int):当前已安装Magisk的版本的代码(整型变量形式的Magisk版本)
# BOOTMODE (bool):如果模块当前安装在Magisk Manager中，则为true。
# MODPATH (path):你的模块应该被安装到的路径
# TMPDIR (path):一个你可以临时存储文件的路径
# ZIPFILE (path):模块的安装包（zip）的路径
# ARCH (string): 设备的体系结构。其值为arm、arm64、x86、x64之一
# IS64BIT (bool):如果$ARCH(上方的ARCH变量)为arm64或x64，则为true。
# API (int):设备的API级别（Android版本）
#
# 可用函数:
#
# ui_print <msg>
#     打印(print)<msg>到控制台
#     避免使用'echo'，因为它不会显示在定制recovery的控制台中。
#
# abort <msg>
#     打印错误信息<msg>到控制台并终止安装
#     避免使用'exit'，因为它会跳过终止的清理步骤
#
##########################################################################################

##########################################################################################
# SKIPUNZIP
##########################################################################################

# 如果您需要更多的自定义，并且希望自己做所有事情
# 请在custom.sh中标注SKIPUNZIP=1
# 以跳过提取操作并应用默认权限/上下文上下文步骤。
# 请注意，这样做后，您的custom.sh将负责自行安装所有内容。
SKIPUNZIP=0

##########################################################################################
# 替换列表
##########################################################################################

# 列出你想在系统中直接替换的所有目录
# 查看文档，了解更多关于Magic Mount如何工作的信息，以及你为什么需要它


# 按照以下格式构建列表
# 这是一个示例
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# 在这里建立您自己的清单
REPLACE="
"
##########################################################################################
# 安装设置
##########################################################################################

# 如果SKIPUNZIP=1您将会需要使用以下代码
# 当然，你也可以自定义安装脚本
# 需要时请删除#
# 将 $ZIPFILE 提取到 $MODPATH
#  ui_print "- 解压模块文件"
#  unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2
# 删除多余文件
# rm -rf \
# $MODPATH/system/placeholder $MODPATH/customize.sh \
# $MODPATH/*.md $MODPATH/.git* $MODPATH/LICENSE 2>/dev/null

TMPDIR=$NVBASE/low_screen_touch_delay
[ -d $TMPDIR ] && rm -rf $TMPDIR
mkdir -p $TMPDIR

unzip -o "$ZIPFILE" module.prop -d $TMPDIR >&2
chmod -R 777 $TMPDIR

MODID=`grep_prop id $TMPDIR/module.prop`
MODAUTHOR=`grep_prop author $TMPDIR/module.prop`
MODNAME=`grep_prop name $TMPDIR/module.prop`
MODVERSION=`grep_prop version $TMPDIR/module.prop`
rm -rf $TMPDIR

vendorprop_systemlib64() {
mkdir -p $NVBASE/modules_update/$MODID/system/
mkdir -p $NVBASE/modules_update/$MODID/system/vendor/
mkdir -p $NVBASE/modules_update/$MODID/system/lib64
cp /vendor/build.prop $NVBASE/modules_update/$MODID/system/vendor/
cp /system/etc/permissions/privapp-permissions-platform.xml$NVBASE/modules_update/$MODID/system/etc/permissions

sleep 1
sed -i "/offset/d" $NVBASE/modules_update/$MODID/system/vendor/build.prop
sed -i "/keystore/d" $NVBASE/modules_update/$MODID/system/vendor/build.prop
sleep 0.2
echo "" >> $NVBASE/modules_update/$MODID/system/vendor/build.prop
echo "" >> $NVBASE/modules_update/$MODID/system/vendor/build.prop
sleep 0.2
echo "" >> $NVBASE/modules_update/$MODID/system/vendor/build.prop
sleep 0.2
echo "debug.sf.use_phase_offsets_as_durations=1" >> $NVBASE/modules_update/$MODID/system/vendor/build.prop
sleep 0.2
echo "debug.sf.late.sf.duration=10500000" >> $NVBASE/modules_update/$MODID/system/vendor/build.prop
sleep 0.2
echo "debug.sf.late.app.duration=16600000" >> $NVBASE/modules_update/$MODID/system/vendor/build.prop
sleep 0.2
echo "debug.sf.treat_170m_as_sRGB=1" >> $NVBASE/modules_update/$MODID/system/vendor/build.prop
sleep 0.2
echo "" >> $NVBASE/modules_update/$MODID/system/vendor/build.prop
sleep 0.2
echo "" >> $NVBASE/modules_update/$MODID/system/vendor/build.prop
sleep 0.2
echo "debug.sf.earlyGl.app.duration=16600000" >> $NVBASE/modules_update/$MODID/system/vendor/build.prop
sleep 0.2
echo "debug.sf.frame_rate_multiple_threshold=120" >> $NVBASE/modules_update/$MODID/system/vendor/build.prop
sleep 0.2

}
print_modname() {
  ui_print "*******************"
  ui_print "  Module Name  ""$MODNAME"
  ui_print "  Version    ""$MODVERSION"
  ui_print "  Author    ：""$MODAUTHOR "
  ui_print "*******************"
}
print_modname
vendorprop_systemlib64
rm -rf $TMPDIR

echo "Installation complete"

##########################################################################################
# 权限设置
##########################################################################################

  #如果添加到此功能，请将其删除

  # 请注意，magisk模块目录中的所有文件/文件夹都有$MODPATH前缀-在所有文件/文件夹中保留此前缀
  # 一些例子:
  
  # 对于目录(包括文件):
  # set_perm_recursive  <目录>                <所有者> <用户组> <目录权限> <文件权限> <上下文> (默认值是: u:object_r:system_file:s0)
  
  # set_perm_recursive $MODPATH/system/lib 0 0 0755 0644
  # set_perm_recursive $MODPATH/system/vendor/lib/soundfx 0 0 0755 0644

  # 对于文件(不包括文件所在目录)
  # set_perm  <文件名>                         <所有者> <用户组> <文件权限> <上下文> (默认值是: u:object_r:system_file:s0)
  
  # set_perm $MODPATH/system/lib/libart.so 0 0 0644
  # set_perm /data/local/tmp/file.txt 0 0 644

  # 默认权限请勿删除
  set_perm_recursive $MODPATH 0 0 0777 0777

