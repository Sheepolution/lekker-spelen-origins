export default class DateTime {
    public static GetNowString() {
        return new Date().toISOString();
    }
}