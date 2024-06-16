export default class Random {

    static Number(a?: number, b?: number, floor?: boolean) {
        if (a == null) { a = 0; b = 1; }
        if (b == null) { b = 0; }

        const r = a + Math.random() * (b - a + (floor ? 1 : 0));
        return floor ? Math.floor(r) : r;
    }

    static Coin() {
        return Math.random() >= .5;
    }

    static Chance(n: number) {
        return this.Number(0, 100) <= n;
    }

    static Dice(n: number) {
        return this.Number(1, n, true);
    }
}