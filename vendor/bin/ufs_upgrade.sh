#!/system/bin/sh
# UFS固件升级脚本（需root权限执行）

# 定义路径常量
FW_VERSION_PATH="/sys/block/sdc/device/rev"
UFS_UTILS="/vendor/bin/ufs-utils"
UFS_FW_FILE="/vendor/firmware/SM2752BB_ASIC_X52A-0_MICRON_B57T_UFS_22_X2_ES_FW_E3M1.smi"

# 定义版本常量
TARGET_VERSION="E3M1"
LEGACY_VERSION="E2Q1"

# 函数：检查文件是否存在且有权限
validate_file() {
    [ -f "$1" ] || { echo "[UFSFFU]ERROR:file does not exist $1" >/dev/kmsg; exit 127; }
    [ -r "$1" ] || { echo "[UFSFFU]ERROR:the file is unreadable $1" >/dev/kmsg; exit 128; }
}

# 函数：获取userdata分区设备路径
get_data_partition() {
    # 通过符号链接解析物理分区路径
    partition_link="/dev/block/by-name/userdata"

    # 双重验证机制
    if ! [ -L "$partition_link" ]; then
        echo "[UFSFFU]ERROR:the userdata symbolic link does not exist" >/dev/kmsg
        exit 132
    fi

    # 方法1：使用readlink获取绝对路径
    data_partition=$(readlink -f "$partition_link" 2>/dev/null | tr -d '\n')

    # 备用方法：使用ls解析路径（兼容没有readlink的设备）
    [ -z "$data_partition" ] && \
        data_partition=$(ls -l "$partition_link" | awk -F '-> ' '{print $2}' | tr -d '[:space:]')

    data_partition=$(echo "$data_partition" | grep -o '[^0-9]*')

    # 最终验证
    if [ -b "$data_partition" ]; then
        echo "$data_partition"
    else
        echo "[UFSFFU]ERROR:unable to resolve valid partition path " >/dev/kmsg
        exit 133
    fi
}

# 函数：执行FFU升级
perform_ffu() {
    echo "[UFSFFU][$(date "+%F %T")]:start ufsffu " >/dev/kmsg
    if $UFS_UTILS ffu -t 0 -g 1 -w "$UFS_FW_FILE" -p "$DATA_PARTITION"; then
        echo "[UFSFFU]firmware upgrade successful " >/dev/kmsg
        return 0
    else
        echo "[UFSFFU]ERROR:firmware upgrade failed " >/dev/kmsg
        return 1
    fi
}

# ------------------ 主执行逻辑 ------------------
main() {
    echo "[UFSFFU]BW ufsffu start" >/dev/kmsg
    # 动态获取数据分区路径
    DATA_PARTITION=$(get_data_partition)
    echo "[UFSFFU]detected data partition path: $DATA_PARTITION" >/dev/kmsg

    # 验证必要文件
    validate_file "$UFS_UTILS"
    validate_file "$UFS_FW_FILE"

    # 获取当前固件版本
    current_fw=$(cat "$FW_VERSION_PATH" | tr -d '[:space:]')
    echo "[UFSFFU]current firmware version: $current_fw" >/dev/kmsg

    # 版本判断逻辑
    case "$current_fw" in
        $TARGET_VERSION)
            echo "[UFSFFU]it is already the latest version, no operation required " >/dev/kmsg
            return 0
            ;;
        *)
            if perform_ffu; then
                echo "[UFSFFU]restarting to update application " >/dev/kmsg
            else
                exit 130
            fi
            ;;
    esac
    echo "[UFSFFU]BW ufsffu end" >/dev/kmsg
}

# 执行主程序
main
