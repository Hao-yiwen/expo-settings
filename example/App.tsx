import { useEffect, useState } from "react";
import { ExpoSettingsView } from "expo-settings";
import { SafeAreaView, View } from "react-native";

const fullMarkdownContent = `
# Markdown 示例
## 基础文本格式
这是一段普通文本，包含**粗体**、*斜体*和***粗斜体***。

## 代码示例
\`\`\`swift
func hello() -> String {
    return "Hello, World!"
}
\`\`\`

## 列表示例
- 项目 1
- 项目 2
  - 子项目 A
  - 子项目 B
`;

export default function App() {
  const [markdownContent, setMarkdownContent] = useState("");
  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    if (currentIndex < fullMarkdownContent.length) {
      const timer = setTimeout(() => {
        setMarkdownContent((prev) => prev + fullMarkdownContent[currentIndex]);
        setCurrentIndex((prev) => prev + 1);
      }, 50); // 每50ms添加一个字符

      return () => clearTimeout(timer);
    }
  }, [currentIndex]);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.view}>
        <ExpoSettingsView
          content={markdownContent}
          onLoad={({ nativeEvent: { status } }) =>
            console.log(`加载状态: ${status}`)
          }
          style={{
            width: '100%',
            backgroundColor: 'white',
          }}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = {
  container: {
    flex: 1,
    backgroundColor: "#eee",
  },
  view: {
    width: "100%",
    backgroundColor: "red",
    justifyContent: "flex-start",
    height: 700,
  },
};
