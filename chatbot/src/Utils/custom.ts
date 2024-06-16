/* eslint-disable no-unused-vars */
/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/naming-convention */
interface String {
    toTitleCase(keep?: boolean): string;
    replaceAll(search: string, replacement: string): string;
    isFilled(trim?: boolean): boolean;
}

interface Array<T> {
    randomChoice(): T;
    shuffle(): T;
    equals(array: Array<T>): boolean;
    filter(test: Array<T>): boolean;
    count(search: string): number;
    insert(index: number, item: T): Array<T>;
    asyncFilter(filterFn: any): Promise<any>
    asyncFind(filterFn: any): Promise<T>
}

String.prototype.toTitleCase = function (keep) {
    if (keep == true) {
        return this.replace(/\w\S*/g, function (txt) { return txt.charAt(0).toUpperCase(); });
    }
    return this.replace(/\w\S*/g, function (txt) { return txt.charAt(0).toUpperCase() + txt.slice(1).toLowerCase(); });
};

String.prototype.replaceAll = function (search, replacement) {
    return this.replace(new RegExp(search, 'g'), replacement);
};

String.prototype.isFilled = function () {
    return this.length > 0;
};

Array.prototype.randomChoice = function () {
    return this[Math.floor(Math.random() * this.length)];
};

Array.prototype.shuffle = function () {
    let j, x, i;
    for (i = this.length - 1; i > 0; i--) {
        j = Math.floor(Math.random() * (i + 1));
        x = this[i];
        this[i] = this[j];
        this[j] = x;
    }

    return this;
};

Array.prototype.equals = function (array) {
    if (this === array) {
        return true;
    }

    if (this.length !== array.length) {
        return false;
    }

    for (let i = 0; i < this.length; i++) {
        if (this[i] !== array[i]) {
            return false;
        }
    }

    return true;
};

Array.prototype.asyncFilter = async function (f) {
    const booleans = await Promise.all(this.map(f));
    return this.filter((x, i) => booleans[i]);
};

Array.prototype.asyncFind = async function (asyncCallback) {
    const promises = this.map(asyncCallback);
    const results = await Promise.all(promises);
    const index = results.findIndex(result => result);
    return this[index];
};