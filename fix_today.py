with open("lib/features/today/today_screen.dart", "r") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "value == 'export_hitem'" in line:
        # Find the closing brace for the onSelected block
        for j in range(i, len(lines)):
            if "}," in lines[j] and "itemBuilder: (context) => [" in lines[j+1]:
                lines[j] = """                                              } else if (value == 'open_url') {
                                                if (item.sourceUrl != null && item.sourceUrl!.isNotEmpty) {
                                                  final uri = Uri.parse(item.sourceUrl!);
                                                  if (await canLaunchUrl(uri)) {
                                                    await launchUrl(uri);
                                                  }
                                                }
                                              }
                                            },\n"""
                break
        
        # Find the end of itemBuilder
        for j in range(i, len(lines)):
            if "]," in lines[j] and ")," in lines[j+1]:
                lines[j] = """                                              if (item.sourceUrl != null && item.sourceUrl!.isNotEmpty)
                                                PopupMenuItem(
                                                  value: 'open_url',
                                                  child: Text('Open Original Link', style: HermesTypography.bodySmall.copyWith(color: HermesColors.evolutioGlow)),
                                                ),
                                            ],\n"""
                break
        break

with open("lib/features/today/today_screen.dart", "w") as f:
    f.writelines(lines)
