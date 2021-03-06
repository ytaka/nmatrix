
int %%TYPE_ABBREV%%gemv(enum CBLAS_TRANSPOSE Trans, const size_t M, const size_t N, const %%TYPE%% alpha,
  const %%TYPE%%* A, const size_t lda, const %%TYPE%%* X, const int incX, const %%TYPE%% beta, %%TYPE%%* Y, const int incY)
{
  size_t lenX, lenY, i, j;
  int kx, ky, iy, jx, jy, ix;
  %%TYPE_LONG%% temp;
  %%= if [:rational,:complex,:value].include?(dtype.type); "#{dtype.long_dtype.sizeof} temp1;"; end%%

  // Test the input parameters
  if (Trans < 111 || Trans > 113) {
    fprintf(stderr, "IGEMV: TransA must be CblasNoTrans, CblasTrans, or CblasConjTrans\n");
    return 0;
  } else if (lda < NM_MAX(1, N)) {
    fprintf(stderr, "IGEMV: Expected lda >= max(1, N), with N = %d; got lda=%d\n", N, lda);
    return 0;
  } else if (incX == 0) {
    fprintf(stderr, "IGEMV: Expected incX != 0\n");
    return 0;
  } else if (incY == 0) {
    fprintf(stderr, "IGEMV: Expected incY != 0\n");
    return 0;
  }

  // Quick return if possible
  if (!M || !N || %%TYPE alpha == 0%% && %%TYPE beta == 1%%) return 0;

  if (Trans == CblasNoTrans) {
    lenX = N;
    lenY = M;
  } else {
    lenX = M;
    lenY = N;
  }

  if (incX > 0) kx = 0;
  else          kx = (lenX - 1) * -incX;

  if (incY > 0) ky = 0;
  else          ky =  (lenY - 1) * -incY;

  // Start the operations. In this version, the elements of A are accessed sequentially with one pass through A.
  if (%%TYPE beta != 1%%) {
    if (incY == 1) {
      if (%%TYPE beta == 0%%) {
        for (i = 0; i < lenY; ++i) {
          %%TYPE Y[i] = 0%%
        }
      } else {
        for (i = 0; i < lenY; ++i) {
          %%TYPE Y[i] *= beta%%
        }
      }
    } else {
      iy = ky;
      if (%%TYPE beta == 0%%) {
        for (i = 0; i < lenY; ++i) {
          %%TYPE Y[iy] = 0%%
          iy += incY;
        }
      } else {
        for (i = 0; i < lenY; ++i) {
          %%TYPE Y[iy] *= beta%%
          iy += incY;
        }
      }
    }
  }

  if (%%TYPE alpha == 0%%) return 0;

  if (Trans == CblasNoTrans) {

    // Form  y := alpha*A*x + y.
    jx = kx;
    if (incY == 1) {
      for (j = 0; j < N; ++j) {
        if (%%TYPE X[jx] != 0%%) {
          %%TYPE_LONG temp = alpha * X[jx]%%
          for (i = 0; i < M; ++i) {
            %%TYPE Y[i] += A[j+i*lda] * temp%%
          }
        }
        jx += incX;
      }
    } else {
      for (j = 0; j < N; ++j) {
        if (%%TYPE X[jx] != 0%%) {
          %%TYPE_LONG temp = alpha * X[jx]%%
          iy = ky;
          for (i = 0; i < M; ++i) {
            %%TYPE Y[iy] += A[j+i*lda] * temp%%
            iy += incY;
          }
        }
        jx += incX;
      }
    }

  } else { // TODO: Check that indices are correct! They're switched for C.

    // Form  y := alpha*A**T*x + y.
    jy = ky;

    if (incX == 1) {
      for (j = 0; j < N; ++j) {
        %%TYPE temp = 0%%
        for (i = 0; i < M; ++i) {
          %%TYPE_LONG temp += A[j+i*lda]*X[j]%%
        }
        %%TYPE Y[jy] += alpha * temp%%
        jy += incY;
      }
    } else {
      for (j = 0; j < N; ++j) {
        %%TYPE temp = 0%%
        ix = kx;
        for (i = 0; i < M; ++i) {
          %%TYPE_LONG temp += A[j+i*lda] * X[ix]%%
          ix += incX;
        }

        %%TYPE Y[jy] += alpha * temp%%
        jy += incY;
      }
    }
  }

  return 0;
}  // end of GEMV
