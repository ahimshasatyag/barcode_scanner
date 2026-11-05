import {
  DarkTheme as NavigationDarkTheme,
  DefaultTheme as NavigationDefaultTheme,
} from "@react-navigation/native";
import merge from "deepmerge";
import {
  MD3LightTheme,
  adaptNavigationTheme,
} from "react-native-paper";

const { LightTheme, DarkTheme } = adaptNavigationTheme({
  reactNavigationLight: NavigationDefaultTheme,
  reactNavigationDark: NavigationDarkTheme,
});

const CombinedDefaultTheme = merge(MD3LightTheme, LightTheme);

export const theme = {
  ...CombinedDefaultTheme,
  dark: false,
  colors: {
    ...CombinedDefaultTheme.colors,
    primary: "#9e0b0f", // Merah elegan untuk elemen utama
    onPrimary: "#FFFFFF", // Teks putih untuk kontras di atas warna utama
    primaryContainer: "#F4C4C5", // Versi lebih terang dari primary untuk background elemen
    onPrimaryContainer: "#600608", // Warna teks di atas primaryContainer
    offPrimaryContainer: "#E0E0E0", // Versi lebih terang dari primary untuk background elemen

    secondary: "#5E2129", // Merah keunguan gelap untuk elemen sekunder
    onSecondary: "#FFFFFF", // Teks putih di atas warna sekunder
    secondaryContainer: "#D69399", // Versi terang untuk background sekunder
    onSecondaryContainer: "#3C1116", // Warna teks di atas secondaryContainer

    tertiary: "#B3475B", // Merah bata sebagai aksen warna
    onTertiary: "#FFFFFF", // Teks putih untuk kontras di atas warna aksen

    background: "#F5F5F5", // Abu-abu terang untuk latar belakang utama
    onBackground: "#2E2E2E", // Teks utama dengan kontras yang nyaman di atas background abu-abu

    surface: "#FFFFFF", // Warna dasar untuk elemen UI seperti card
    onSurface: "#3D1C20", // Warna teks di atas elemen surface
    surfaceVariant: "#E0E0E0", // Abu-abu netral untuk varian permukaan
    onSurfaceVariant: "#5A2D32", // Warna teks di atas surfaceVariant

    outline: "#7A3E42", // Warna abu-abu kemerahan untuk border
    outlineVariant: "#BFA5A7", // Varian outline untuk elemen yang lebih lembut

    inverseSurface: "#2C2C2C", // Warna surface untuk mode gelap
    inverseOnSurface: "#F5F5F5", // Teks terang untuk mode gelap
    inversePrimary: "#F4C4C5", // Warna primary dalam mode gelap

    elevation: {
      level0: "white",
      level1: "#F8F8F8",
      level2: "#F2F2F2",
      level3: "#ECECEC",
      level4: "#E6E6E6",
      level5: "#DFDFDF",
    },

    surfaceDisabled: "rgba(46, 46, 46, 0.12)", // Warna untuk elemen yang tidak aktif
    onSurfaceDisabled: "rgba(46, 46, 46, 0.38)", // Warna teks di atas elemen yang nonaktif
    backdrop: "rgba(28, 28, 28, 0.5)", // Warna overlay untuk modal/dialog

    card: "#FFFFFF", // Warna kartu navigasi
    text: "#2E2E2E", // Warna teks utama yang lebih gelap untuk kontras di atas background abu-abu
    border: "#CCCCCC", // Warna garis batas yang lebih lembut
    notification: "#E63946", // Warna merah terang untuk notifikasi

    statusColors: {
      // Attendance
      Present: "#4caf50",
      Late: "#ff9800",
      Absent: "#f44336",
      "Left Early": "#2196f3",
      "No Clock Out": "#607d8b",

      // Cuti
      Pending: "#2196f3",
      Approved: "#4caf50",
      Rejected: "#ff7043",
      Canceled: "#f44336",

      // Request Form
      DRAFT: "#2196f3",
      CONFIRMED: "#3ddad7",
      CANCELED: "#f44336",
      PAID: "#4caf50",

      // Lead Status
      NEW: "#2196f3",
      OPEN: "#4CAF50",
      CANCEL: "#F44336",
      FAIL: "#9E9E9E",
      SUCCESS: "#2196F3",
    },
  },
}
