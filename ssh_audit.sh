#!/bin/bash
# Linux SSH异常登录审计工具
# 读取auth.log，检测暴力破解、root远程登录，支持IP白名单

LOG_FILE="/var/log/auth.log"
REPORT_FILE="./ssh_audit_report.txt"
# 阈值：同一IP失败登录超过5次判定为暴力破解
FAIL_THRESHOLD=5
# IP白名单，多个IP空格隔开
WHITE_LIST=("127.0.0.1" "192.168.1.1")

# 清空上次报告
> $REPORT_FILE

echo "==================== SSH安全审计报告 ====================" | tee -a $REPORT_FILE
echo "审计时间: $(date)" | tee -a $REPORT_FILE
echo "==========================================================" | tee -a $REPORT_FILE

# 1. 检测Root账号SSH远程登录
echo -e "\n[1] Root远程登录行为检测" | tee -a $REPORT_FILE
root_login_records=$(grep "sshd.*root" $LOG_FILE | grep "Accepted publickey\|Accepted password")
if [ -n "$root_login_records" ];then
    echo "⚠️ 发现root账号直接SSH远程登录记录！" | tee -a $REPORT_FILE
    echo "$root_login_records" | tee -a $REPORT_FILE
else
    echo "✅ 未发现root账号SSH远程登录记录" | tee -a $REPORT_FILE
fi

# 2. 统计SSH登录失败IP，暴力破解检测
echo -e "\n[2] SSH登录失败&暴力破解检测" | tee -a $REPORT_FILE
# 提取所有SSH密码失败的IP
fail_ips=$(grep "sshd.*Failed password" $LOG_FILE | awk '{print $(NF-3)}' | sort | uniq -c)

if [[ -z "$fail_ips" ]];then
    echo "✅ 未检测到SSH密码登录失败记录" | tee -a $REPORT_FILE
else
    while read -r count ip; do
        # 判断IP是否在白名单
        in_white=0
        for wip in "${WHITE_LIST[@]}";do
            if [ "$ip" == "$wip" ];then
                in_white=1
                break
            fi
        done
        if [ $in_white -eq 1 ];then
            echo "ℹ️ 白名单IP：$ip 失败次数:$count，跳过告警" | tee -a $REPORT_FILE
            continue
        fi
        if [ $count -ge $FAIL_THRESHOLD ];then
            echo "🔴 告警！IP $ip 失败登录 $count 次，疑似暴力破解" | tee -a $REPORT_FILE
        else
            echo "🟡 记录：IP $ip 失败登录 $count 次" | tee -a $REPORT_FILE
        fi
    done <<< "$fail_ips"
fi

# 3. 统计成功登录记录
echo -e "\n[3] 所有SSH成功登录记录" | tee -a $REPORT_FILE
success_logs=$(grep "sshd.*Accepted" $LOG_FILE)
if [[ -z "$success_logs" ]];then
    echo "✅ 暂无SSH成功登录记录" | tee -a $REPORT_FILE
else
    echo "$success_logs" | tee -a $REPORT_FILE
fi

echo -e "\n==================== 审计结束，报告已保存至 $REPORT_FILE ===================="
