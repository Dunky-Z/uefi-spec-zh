# 概述

---

UEFI 允许通过加载 UEFI 驱动程序和 UEFI 应用程序映像来扩展平台固件。加载 UEFI 驱动程序和 UEFI 应用程序后，它们可以访问所有 UEFI 定义的运行时和启动服务。见图 2-1

---

![启动顺序](../pic/2-1.jpg "启动顺序")

---

UEFI 允许将来自 OS 加载程序和平台固件的引导菜单合并到单个平台固件菜单中。这些平台固件菜单，将允许从 UEFI 引导服务支持的任何引导介质上的任何分区中选择任何 UEFI OS 加载程序。UEFI OS 加载程序可以支持可以出现在用户界面上的多个选项。还可以包括传统引导选项，例如从平台固件引导菜单中的 A: 或 C: 驱动器引导。

UEFI 支持从包含 UEFI 操作系统加载程序或 UEFI 定义的系统分区的媒介引导。 UEFI 需要 UEFI 定义的系统分区才能从块设备引导。 UEFI 不需要对分区的第一个扇区进行任何更改，因此可以构建媒介在旧架构和 UEFI 平台上启动。

## 要求

本文件是一个架构规范。因此，在实现中保留了最大的灵活度。但是，有一些要求，这个规范的元素必须被实现，以确保操作系统加载器和其他设计成与 UEFI 启动服务一起运行的代码可以依赖一个一致的环境。为了描述这些要求，这个规范被分成了必要的和可选的元素。一般来说，一个可选的元素在与该元素名称相匹配的章节中被完全定义。然而，对于必需的元素，在少数情况下，定义可能不完全包含在为特定元素命名的部分中。在实现必要元素时，应该注意涵盖本规范中定义的与特定元素相关的所有语义。

### 必要元素

表 2-11 列出了所需必要元素。任何符合本规范的系统，都必须实现这些元素。这意味着所有必要的服务功能和协议都必须存在，并且实现必须为所有的调用和参数组合提供规范中定义的全部语义。应用程序、驱动程序或操作系统加载器，他们可以假设所有这些系统都实现了所有的必要要素

系统供应商可能会选择不实现所有要求的元素，例如，在专门的系统配置上，不支持要求的元素所隐含的所有服务和功能。然而，由于大多数应用程序、驱动程序和操作系统加载器的编写是假设所有必要的元素都存在于实现 UEFI 规范的系统上；任何这样的代码都可能需要明确的定制，以运行在对该规范中所要求的元素的不完全实现。

### 平台特定的元素

根据平台所需的特定功能，可以添加或删除许多元素。平台固件开发者需要根据所包含的功能来实现 UEFI 元素。以下是可能的平台特征和每种特征类型所需的要素清单：

1. 如果一个平台包括控制台设备，必须实现`EFI_SIMPLE_TEXT_INPUT_PROTOCOL`、`EFI_SIMPLE_TEXT_INPUT_EX_PROTOCOL`和`EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL`。
2. 如果一个平台包括一个配置基础设施，那么`EFI_HII_DATABASE_PROTOCOL`,`EFI_HII_STRING_PROTOCOL`, `EFI_HII_CONFIG_ROUTING_PROTOCOL`, `EFI_HII_CONFIG_ACCESS_PROTOCOL`是必须的。如果你支持位图字体，你必须支持`EFI_HII_FONT_PROTOCOL`。
3. 如果一个平台包括图形控制台设备，那么必须实现 `EFI_GRAPHICS_OUTPUT_PROTOCOL`、`EFI_EDID_DISCOVERED_PROTOCOL` 和 `EFI_EDID_ACTIVE_PROTOCOL`。为了支持 `EFI_GRAPHICS_OUTPUT_PROTOCOL`，一个平台必须包含一个驱动程序来消费 `EFI_GRAPHICS_OUTPUT_PROTOCOL` 并产生 `EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL`，即使 `EFI_GRAPHICS_OUTPUT_PROTOCOL` 是由一个外部驱动程序产生的。
4. 如果一个平台包括一个指针设备作为其控制台支持的一部分，`EFI_SIMPLE_POINTER_PROTOCOL` 必须被实现。
5. 如果一个平台包括从磁盘设备启动的能力，那么就需要 `EFI_BLOCK_IO_PROTOCOL`、`EFI_DISK_IO_PROTOCOL`、`EFI_SIMPLE_FILE_SYSTEM_PROTOCOL` 以及 `EFI_UNICODE_COLLATION_PROTOCOL`。此外，必须实现对 `MBR`、`GPT` 和 El `Torito` 的分区支持。对于支持 SPC-4 或 ATA8-ACS 命令集安全命令的磁盘设备，还需要 `EFI_STORAGE_SECURITY_COMMAND_PROTOCOL`。（TODO 原文多了下划线）外部驱动程序可以产生块 I/O 协议和 `EFI_STORAGE_SECURITY_COMMAND_PROTOCOL`。所有其他从磁盘设备启动所需的协议必须作为平台的一部分进行。
6. 如果一个平台可以从网络设备 TFTP 启动，那么就需要 `EFI_PXE_BASE_CODE_PROTOCOL`。平台必须准备好在 `EFI_NETWORK_INTERFACE_IDENTIFIER_PROTOCOL(UNDI)`、`EFI_SIMPLE_NETWORK_PROTOCOL` 或 `EFI_MANAGED_NETWORK_PROTOCOL` 中的任何一种上产生这个协议。如果平台包括验证通过网络设备收到的启动镜像的能力。也需要支持映像验证，包括 *`SetupMode`* 等于 0，引导映像的哈希值或映像对应的验证证书存在于'db'变量而不是'dbx'变量中。一个外部驱动可以产生 UNDI 接口。从网络设备启动所需的所有其他协议必须由平台来执行。
7. 如果一个平台支持 UEFI 通用网络应用，那么 `EFI_MANAGED_NETWORK_PROTOCOL`, `EFI_MANAGED_NETWORK_SERVICE_BINDING_PROTOCOL`, `EFI_ARP_PROTOCOL`, `EFI_ARP_SERVICE_BINDING_PROTOCOL`, `EFI_DHCP4_PROTOCOL`, `EFI_DHCP4_SERVICE_BINDING_PROTOCOL`。 `EFI_TCP4_PROTOCOL`, `EFI_TCP4_SERVICE_BINDING_PROTOCOL`, `EFI_IP4_PROTOCOL`, `EFI_IP4_SERVICE_BINDING_PROTOCOL`, `EFI_IP4_CONFIG2_PROTOCOL`, `EFI_UDP4_PROTOCOL` 和 `EFI_UDP4_SERVICE_BINDING_PROTOCOL` 是必需的。如果该平台需要额外的 IPv6 支持，那么需要 `EFI_DHCP6_PROTOCOL、EFI_DHCP6_SERVICE_BINDING_PROTOCOL`、`EFI_TCP6_PROTOCOL`、`EFI_TCP6_SERVICE_BINDING_PROTOCOL`。`EFI_IP6_PROTOCOL`、`EFI_IP6_SERVICE_BINDING_PROTOCOL`、`EFI_IP6_CONFIG_PROTOCOL`、`EFI_UDP6_PROTOCOL` 和 `EFI_UDP6_SERVICE_BINDING_PROTOCOL` 是额外要求的。如果网络应用需要 DNS 功能，`EFI_DNS4_SERVICE_BINDING_PROTOCOL` 和 `EFI_DNS4_PROTOCOL` 是 IPv4 协议栈的必备条件。IPv6 协议栈需要 `EFI_DNS6_SERVICE_BINDING_PROTOCOL` 和 `EFI_DNS6_PROTOCOL`。如果网络环境需要 `TLS` 功能，需要 `EFI_TLS_SERVICE_BINDING_PROTOCOL`、`EFI_TLS_PROTOCOL` 和 `EFI_TLS_CONFIGURATION_PROTOCOL`。如果网络环境需要 `IPSEC` 功能，需要 `EFI_IPSEC_CONFIG_PROTOCOL` 和 `EFI_IPSEC2_PROTOCOL`。如果网络环境需要 VLAN 功能，需要 `EFI_VLAN_CONFIG_PROTOCOL`。
8. 如果一个平台包括一个字节流设备，如 UART，那么 `EFI_SERIAL_IO_PROTOCOL` 必须被实现。
9. 如果一个平台包括 PCI 总线支持，那么 `EFI_PCI_ROOT_BRIDGE_IO_PROTOCOL`，`EFI_PCI_IO_PROTOCOL`，必须被实现。
10. 如果一个平台包括 USB 总线支持，那么必须实现 `EFI_USB2_HC_PROTOCOL` 和 `EFI_USB_IO_PROTOCOL`。一个外部设备可以通过产生一个 USB 主机控制器协议来支持 USB。
11. 如果一个平台包括一个 NVM Express 控制器，那么必须实现 `EFI_NVM_EXPRESS_PASS_THRU_PROTOCOL`。
12. 如果一个平台支持从面向块的 NVM Express 控制器启动，那么必须实现 `EFI_BLOCK_IO_PROTOCOL`。一个外部驱动程序可以产生 `EFI_NVM_EXPRESS_PASS_THRU_PROTOCOL`。从 NVM Express 子系统启动所需的所有其他协议必须由平台携带。
13. 如果一个平台包括一个利用SCSI命令包的I/O子系统，那么`EFI_EXT_SCSI_PASS_THRU_PROTOCOL`必须被实现。
14. 如果一个平台支持从面向块的 SCSI 外设启动，那么必须实现 `EFI_SCSI_IO_PROTOCOL` 和 `EFI_BLOCK_IO_PROTOCOL`。一个外部驱动程序可以产生 `EFI_EXT_SCSI_PASS_THRU_PROTOCO`L。从 SCSI I/O子系统启动所需的所有其他协议必须由平台携带。
15. 如果一个平台支持从 iSCSI 外围启动，那么必须实现 `EFI_ISCSI_INITIATOR_NAME_PROTOCOL` 和 `EFI_AUTHENTICATION_INFO_PROTOCOL`。
16. 如果一个平台包括调试功能，那么 `EFI_DEBUG_SUPPORT_PROTOCOL`、`EFI_DEBUGPORT_PROTOCOL` 和 EFI 图像信息表必须被实现。
17. 如果一个平台包括将默认驱动程序覆盖到 UEFI 驱动程序模型提供的控制器匹配算法的能力，那么必须实现 `EFI_PLATFORM_DRIVER_OVERRIDE_PROTOCOL`。
18. 如果一个平台包括一个利用ATA命令包的I/O子系统，那么必须实现`EFI_ATA_PASS_THRU_PROTOCOL`。
19. 如果一个平台支持来自非永久连接到平台的设备的选项 ROM，并且支持验证这些选项 ROM 的能力，那么它必须支持《网络协议-UDP 和 MTFTP》中描述的选项 ROM 验证方法和第 8.1.1 节中描述的验证 EFI 变量。
20. 如果一个平台包括验证 UEFI 图像的能力，并且该平台可能支持一个以上的操作系统加载器，它必须支持网络协议--UDP 和 MTFTP 中描述的方法以及第 8.1.1 节中描述的验证 UEFI 变量。
21. 从 UEFI 规范 2.8 版开始，不再需要 EBC 支持。如果一个 EBC 解释器被实现，那么它必须产生 `EFI_EBC_PROTOCOL` 接口。