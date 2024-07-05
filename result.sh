#!/bin/bash

input_file=""
output_file="extracted_content.txt"

# 解析命令行参数
while getopts "i:o:" opt; do
  case $opt in
    i) input_file="$OPTARG";;
    o) output_file="$OPTARG";;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
  esac
done

# 检查输入文件名是否为空
if [ -z "$input_file" ]; then
  echo "Error: Missing input file. Please specify with -i option." >&2
  exit 1
fi

# 提取匹配的行并写入输出文件
grep -E "^Running|^Complete in|^Thread ops/sec|^Insert:|^Lookup:|^Erase:|^Lookup hit ratio|^Count:" "$input_file" > "$output_file"

# 提示操作完成
echo "提取完成，结果已写入 $output_file"
