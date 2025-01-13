// ExpoSettings.types.ts
import type { StyleProp, ViewStyle } from 'react-native';

export type OnLoadEventPayload = {
  status: string;
};

export type ExpoSettingsViewProps = {
  content: string;
  onLoad?: (event: { nativeEvent: OnLoadEventPayload }) => void;
  style?: StyleProp<ViewStyle>;
};