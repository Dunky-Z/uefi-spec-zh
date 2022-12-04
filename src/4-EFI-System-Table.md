# EFI System Table

本节介绍 UEFI 映像的入口点以及传递到该入口点的参数。符合本规范的固件可以加载和执行三种类型的 UEFI 映像。它们是 UEFI 应用程序（参见第 2.1.2 节）、UEFI 引导服务驱动程序（参见第 2.1.4 节）和 UEFI 运行时驱动程序（参见第 2.1.4 节）。UEFI 应用程序包括 UEFI OS 加载程序（参见第 2.1.3 节）。这三种镜像类型的入口点没有区别。

## UEFI Image Entry Point

传递给图像的最重要参数是指向系统表的指针。该指针是 EFI_IMAGE_ENTRY_POINT（参见下面的定义），它是 UEFI 映像的主要入口点。系统表包含指向活动控制台设备的指针、指向启动服务表的指针、指向运行时服务表的指针以及指向系统配置表（如 ACPI、SMBIOS 和 SAL 系统表）列表的指针。本节详细介绍系统表。

**EFI_IMAGE_ENTRY_POINT**

**概述**

这是 UEFI 映像的主要入口点。此入口点对于 UEFI 应用程序和 UEFI 驱动程序是相同的。

**原型**

```C
typedef
EFI_STATUS
(EFIAPI *EFI_IMAGE_ENTRY_POINT) (
IN EFI_HANDLE ImageHandle,
IN EFI_SYSTEM_TABLE *SystemTable
);
```

**参数**

- ImageHandle:为 UEFI 映像分配的固件句柄
- SystemTable:指向 EFI 系统表的指针

**描述**

此函数是 EFI 映像的入口点。EFI 映像由 EFI 引导服务`EFI_BOOT_SERVICES.LoadImage()` 加载并重新定位在系统内存中。EFI 映像通过 EFI 引导服务 `EFI_BOOT_SERVICES.StartImage()` 调用。

传递给图像的最重要参数是指向系统表的指针。这个指针是 EFI_IMAGE_ENTRY_POINT（见下面的定义），UEFI Image 的主要入口点。系统表包含指向活动控制台设备的指针、指向引导服务表的指针、指向运行时服务表的指针以及指向系统配置表列表（例如 ACPI、SMBIOS 和 SAL 系统表）的指针。本节详细介绍系统表。

ImageHandle 是固件分配的句柄，用于在各种功能上识别图像。该句柄还支持图像可以使用的一种或多种协议。所有图像都支持 `EFI_LOADED_IMAGE_PROTOCOL` 和 `EFI_LOADED_IMAGE_DEVICE_PATH_PROTOCOL`，它们返回图像的源位置、图像的内存位置、图像的加载选项等。确切的 `EFI_LOADED_IMAGE_PROTOCOL` 和 `EFI_LOADED_IMAGE_DEVICE_PATH_PROTOCOL` 结构在第 9 节中定义。

如果 UEFI 映像是不是 UEFI 操作系统加载程序的 UEFI 应用程序，则该应用程序将执行并返回或调用 EFI 引导服务 `EFI_BOOT_SERVICES.Exit()`。UEFI 应用程序在退出时总是从内存中卸载，并将其返回状态返回给启动该 UEFI 应用程序的组件。

如果 UEFI 映像是 UEFI 操作系统加载程序，则 UEFI 操作系统加载程序将执行并返回，调用 EFI 引导服务 `Exit()`，或调用 EFI 引导服务 `EFI_BOOT_SERVICES.ExitBootServices()`。如果 EFI OS Loader 返回或调用 `Exit()`，则 OS 加载失败，EFI OS Loader 从内存中卸载，控制权返回到尝试启动 UEFI OS Loader 的组件。如果调用了 `ExitBootServices()`，那么 UEFI OS Loader 已经控制了平台，EFI 将不会重新获得系统的控制权，直到平台被重置。重置平台的一种方法是通过 EFI 运行时服务 `ResetSystem()`。

如果 UEFI 映像是 UEFI 驱动程序，则 UEFI 驱动程序将执行并返回或调用 Boot Service `Exit()`。如果 UEFI 驱动程序返回错误，则驱动程序将从内存中卸载。如果 UEFI 驱动程序返回 `EFI_SUCCESS`，则它会驻留在内存中。如果 UEFI 驱动程序不遵循 UEFI 驱动程序模型，则它会执行任何必需的初始化并在返回之前安装其协议服务。如果驱动程序确实遵循 UEFI 驱动程序模型，则不允许入口点接触任何设备硬件。相反，入口点需要在 UEFI 驱动程序的 `ImageHandle` 上创建和安装 `EFI_DRIVER_BINDING_PROTOCOL`（请参阅第 11.1 节）。如果此过程完成，则返回 `EFI_SUCCESS`。如果资源不可用于完成 UEFI 驱动程序初始化，则返回 `EFI_OUT_OF_RESOURCES`。

**返回的状态码**

- EFI_SUCCESS：驱动程序已初始化。
- EFI_OUT_OF_RESOURCES：由于缺乏资源，请求无法完成。

## EFI 表头

数据类型 EFI_TABLE_HEADER 是所有标准 EFI 表类型之前的数据结构。它包括对每个表类型唯一的签名、可以在扩展添加到 EFI 表类型时更新的表修订以及一个 32 位 CRC，因此 EFI 表类型的消费者可以验证 EFI 表类型的内容 EFI 表。

**EFI_TABLE_HEADER**

**概述**

在所有标准 EFI 表类型之前的数据结构。

**原型**

```C
typedef struct {
    UINT64 Signature;
    UINT32 Revision;
    UINT32 HeaderSize;
    UINT32 CRC32;
    UINT32 Reserved;
} EFI_TABLE_HEADER;
```

**参数**

- Signature:标识后面的表类型的 64 位签名。已为 EFI 系统表、EFI 引导服务表和 EFI 运行时服务表生成唯一签名。
- Revision:此表符合的 EFI 规范的修订版。该字段的高 16 位包含主修订值，低 16 位包含次修订值。次要修订值是二进制编码的十进制数，并且限制在 00..99 的范围内。
  - 当打印或显示时，UEFI 规范修订被称为（主要修订）。（次要修订上位小数）。（次要修订小数下位）或（主要修订）。（次要修订小数点上位）如果次要修订小数下位设置为 0。例如
  - 具有修订值 ((2<<16) | (30)) 的规范将称为 2.3
  - 具有修订值 ((2<<16) | (31)) 的规范将称为 2.3.1
- HeaderSize:整个表的大小（以字节为单位），包括 EFI_TABLE_HEADER。
- CRC32：整个表的 32 位 CRC。通过将此字段设置为 0 并计算 HeaderSize 字节的 32 位 CRC 来计算此值
- Reserved：必须设置为 0 的保留字段。

**描述**

EFI 系统表、运行时表和引导服务表中的功能可能会随时间发生变化。每个表中的第一个字段是 EFI_TABLE_HEADER。当新的能力和功能被添加到表中的功能时，此标头的修订字段会增加。检查功能时，代码应验证 Revision 是否大于或等于将功能添加到 UEFI 规范时表的修订级别。

除非另有说明，否则 UEFI 使用标准 CCITT32 CRC 算法进行 CRC 计算，其种子多项式值为 0x04c11db7。

系统表、运行时服务表和引导服务表的大小可能会随着时间的推移而增加。始终使用 EFI_TABLE_HEADER 的 HeaderSize 字段来确定这些表的大小非常重要。