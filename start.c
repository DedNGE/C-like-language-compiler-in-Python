double complexMath(double x, double y) {
    return sin(x) * cos(y) + pow(x, y) - sqrt(fabs(x - y));
}

int bitOperations(int num) {
    return (num << 2) | (num >> 3) ^ (num & 255) + (num | 255);
}

double financialCalculations(double principal, double rate, int years) {
    double compoundInterest = principal * pow(1 + rate / 100.0, years);
    double simpleInterest = principal * (1 + rate / 100.0 * years);
    return compoundInterest + simpleInterest;
}

double temperatureConversions(double celsius) {
    double fahrenheit = celsius * 9.0 / 5.0 + 32.0;
    double kelvin = celsius + 273.15;
    return fahrenheit + kelvin;
}

int main() {
    double finalResult, arithmetic1, arithmetic2, arithmetic3, arithmetic4, arithmetic5;
    double math1, math2, math3, trig1, trig2, trig3, trig4, trig5;
    double trig6, trig7, trig8, trig9, trig10, finance, temp, complex;
    double extra1, extra2, extra3, extra4, extra5, extra6, extra7, extra8, extra9;

    int finalInt, a, b, c, int1, int2, int3, int4, int5, int6;
    int bit1, bit2, bit3, bit4, bit5, bit6, bitFunc, bitAdd, res, castResult;

    finalResult = 0.0;
    finalInt = 0;

    arithmetic1 = (15.0 + 7.0);
    arithmetic2 = (23.0 - 4.0);
    arithmetic3 = (5.0 + 2.0);
    arithmetic4 = arithmetic1 * arithmetic2;
    arithmetic5 = arithmetic4 / arithmetic3;
    finalResult = finalResult + arithmetic5;

    math1 = fmod(28.0, 3.0);
    math2 = pow(2.0, 3.0);
    math3 = math1 * math2;
    finalResult = finalResult + math3;

    trig1 = sin(0.5);
    trig2 = cos(0.3);
    trig3 = tan(0.1);
    trig4 = trig1 * trig2;
    trig5 = trig4 + trig3;
    trig6 = trig5 / 2.0;
    trig7 = trig5 / 3.0;
    trig8 = asin(trig6);
    trig9 = acos(trig7);
    trig10 = trig8 * trig9;
    finalResult = finalResult + trig10;
    a = 25;
    b = 13;
    c = 7;
    int1 = a * b;
    int2 = int1 + c;
    int3 = b - c;
    int4 = int2 // int3;
    int5 = a + b;
    int6 = int4 % int5;
    finalInt = finalInt + int6;

    bit1 = a & b;
    bit2 = c % 4;
    bit3 = bit1 << bit2;
    bit4 = a | b;
    bit5 = c // 2;
    bit6 = bit4 >> bit5;
    finalInt = finalInt | bit3;
    finalInt = finalInt ^ bit6;

    bitFunc = bitOperations(42);
    bitAdd = bitFunc + 17;
    finalInt = finalInt + bitAdd;

    finance = financialCalculations(1000.0, 5.0, 10);
    finalResult = finalResult + finance;

    temp = temperatureConversions(25.0);
    finalResult = finalResult + temp;

    complex = complexMath(2.0, 3.0);
    finalResult = finalResult + complex;

    extra1 = tan(10.0 / 6.0);
    extra2 = tan(1.0);
    extra3 = extra1 * extra2;
    finalResult = finalResult + extra3;

    extra4 = exp(1.0);
    extra5 = log(10.0);
    extra6 = extra4 * extra5;
    finalResult = finalResult + extra6;

    extra7 = sqrt(144.0);
    extra8 = log(27.0);
    extra9 = extra7 * extra8;
    finalResult = finalResult + extra9;

    res = 2 + 3 + 4;
    castResult = (int)finalResult;
    finalInt = finalInt + castResult + res;

    printf("Результат: %.3f\n", finalResult);
    printf("Целочисленный результат: %d\n", finalInt);
    
    return 0;
}