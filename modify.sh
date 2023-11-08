# 这个脚本会计算文件的最后修改时间与当前updated时间之间的差距（以秒为单位），
# 如果差距超过1分钟（60秒），则会更新updated字段后面的时间为文件的最后修改时间。
# 如果不存在updated字段，它将在date字段下一行添加updated字段，并将时间设置为文件的最后修改时间。
# Author: 李一航
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
        # 使用stat命令获取文件的修改时间的时间戳
        mtime_timestamp=$(stat -c "%Y" "$file_path")
        # 使用date命令格式化时间戳为指定的日期和时间格式
        formatted_mtime=$(date -d "@$mtime_timestamp" "+%Y-%m-%d %H:%M:%S")

        # 检查文件中是否包含updated字段
        if grep -q "updated:" "$file_path"; then
            # 提取文件中的updated字段后的时间部分
            current_updated_time=$(grep "updated:" "$file_path" | sed -n 's/updated: //p')
            
            # 将时间字符串转换为时间戳
            current_updated_timestamp=$(date -d "$current_updated_time" "+%s")
            
            # 计算文件的最后修改时间与当前updated时间之间的差距
            time_difference=$((mtime_timestamp - current_updated_timestamp))
            
            # 如果差距超过1分钟（60秒），将updated字段后面的时间改为文件的最后修改时间
            if [ $time_difference -gt 60 ]; then
                # 用sed命令更新updated字段的时间
                sed -i "s/\(updated: \).*/\1$formatted_mtime/" "$file_path"
                echo "已更新文件 '$file_path' 的updated字段为: $formatted_mtime"
            fi
        else
            # 如果不存在updated字段，找到第一次出现的date字段，并在其下一行添加updated字段
            if grep -q "date:" "$file_path"; then
                line_number=$(grep -n "date:" "$file_path" | head -n 1 | cut -d ':' -f 1)
                sed -i "${line_number}a updated: $formatted_mtime" "$file_path"
                echo "已添加updated字段到文件 '$file_path'，时间为: $formatted_mtime"
            fi
        fi
    done
fi
