declare module 'lunar-typescript' {
    export class Solar {
        static fromYmd(year: number, month: number, day: number): Solar;
        getLunar(): Lunar;
    }

    export class Lunar {
        getYearInChinese(): string;
        getMonthInChinese(): string;
        getDayInChinese(): string;
        getEightChar(): any;
    }
} 