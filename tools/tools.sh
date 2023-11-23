#!/bin/bash
#基本判断
#$1 判断条件
#$2 结果为真的输出
#$3 结果为假的输出
is_true(){
  if [ "$1" ]; then
      echo "$2"
      return 1
  else
      echo "$3"
      return 0
  fi
}

#判断变量是否为空
#$1 判断的变量
#$2 存在的输出
#$3 不存在的输出
is_empty(){
  if [ -z "$1" ]; then
      echo "$2"
      return 1
  else
      echo "$3"
      return 0
  fi
}

#判断文件是否存在
#$1 判断的文件
#$2 存在的输出
#$3 不存在的输出
is_exist(){
  if [ -f "$1" ]; then
      echo "$2"
      return 1
  else
      echo "$3"
      return 0
  fi
}
