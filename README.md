# SSH-Login-Audit-Tool
CIS基线安全审计工具，支持Linux系统SSH暴力破解检测、Root远程登录审计

# SSH-Login-Audit-Tool
Linux SSH登录安全审计工具，用于检测SSH异常登录行为。

## 功能介绍
- 检测Root账号SSH远程登录行为
- 统计SSH登录失败次数，识别疑似暴力破解攻击
- 输出格式化安全审计报告

## 环境要求
Ubuntu Linux，已开启SSH服务

## 使用方法
```bash
# 赋予脚本执行权限
chmod +x ssh_audit.sh
# 执行审计脚本
sudo bash ssh_audit.sh
