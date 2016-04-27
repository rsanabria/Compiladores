#define PI $3.1415
main() {
    float radio=4.0, lado=7.0, areaCir, areaCua;
#ifdef PI
    areaCir=radio*radio*PI;
#else
    areaCir=radio*radio*3.1416;
#endif
    areaCua=lado*lado;
}