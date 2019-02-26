# 本模块使用了clang的动态库libclang.dylib的python绑定来对源代码文件进行词法分析，输出所有的token
# Created by Linyongzhi on 2017-06-09.

import sys
import clang.cindex

# 需要指定libclang.dylib的路径
clang.cindex.Config.set_library_path(
  "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib")

def srcrangestr(x):
    return '%s:%d:%d - %s:%d:%d' % (x.start.file, x.start.line, x.start.column, x.end.file, x.end.line, x.end.column)

def main():
    index = clang.cindex.Index.create()
    tu = index.parse(sys.argv[1], args=[])

    for x in tu.cursor.get_tokens():
        print(x.kind)
        print("  " + srcrangestr(x.extent))
        print("  '" + str(x.spelling) + "'")

if __name__ == '__main__':
    main()