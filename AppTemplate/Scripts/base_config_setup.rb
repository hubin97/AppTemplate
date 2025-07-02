#
#  base_config_setup.rb
#  AppTemplate
#
#  Created by hubin.h on 2025/7/2.
#  Copyright © 2025 Hubin_Huang. All rights reserved.

# 基础配置
# 导入 privacy_manifest_utils.rb 文件 (整合更新Pods包含的隐私清单, 注意`PrivacyInfo`必须放在根目录, 且勾选target)
require_relative './privacy_manifest_utils.rb'
$START_TIME = Time.now.to_i

def base_config_setup(
  installer,
  privacy_file_aggregation_enabled: true
)
  if privacy_file_aggregation_enabled
    PrivacyManifestUtils.add_aggregated_privacy_manifest(installer)
  else
    PrivacyManifestUtils.add_privacy_manifest_if_needed(installer)
  end

  Pod::UI.puts "base_config_setup install took #{Time.now.to_i - $START_TIME} [s] to run".green
end
