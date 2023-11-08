# 打印所有.md文件的最后修改时间
#!/bin/bash

# 指定要检测的目录路径
directory_path="_posts"

# 使用find命令查找所有.md文件，并将结果存储在一个数组中
md_files=($(find "$directory_path" -type f -name "*.md"))

# 检查是否找到了.md文件
if [ ${#md_files[@]} -eq 0 ]; then
    echo "未找到任何.md文件在目录 '$directory_path' 中."
else
    # 遍历数组并获取每个.md文件的修改时间
    for file_path in "${md_files[@]}"; do
        # 使用stat命令获取修改时间的时间戳
        mtime_timestamp=$(stat -c "%Y" "$file_path")
        # 使用date命令格式化时间戳为指定格式
        formatted_mtime=$(date -d "@$mtime_timestamp" "+%Y-%m-%d %H:%M:%S")
        # 提取文件名
        file_name=$(basename "$file_path")
        # 显示结果
        echo "文件 '$file_name' 的修改时间是: $formatted_mtime"
    done
fi
