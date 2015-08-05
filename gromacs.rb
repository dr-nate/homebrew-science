require "formula"

class Gromacs < Formula
  homepage "http://www.gromacs.org/"
  version "5.0.6"
  url "ftp://ftp.gromacs.org/pub/gromacs/gromacs-5.0.6.tar.gz"
  mirror "http://fossies.org/linux/privat/gromacs-5.0.6.tar.gz"
  sha256 "e07e950c4cd6cb84b83b145b70a15c25338ad6a7d7d1a0a83cdbd51cad954952"

  deprecated_option "with-x" => "with-x11"
  deprecated_option "enable-mpi" => "with-mpi"

  option "enable-double","Enables double precision"
  option "without-check", "Skip build-time tests (not recommended)"

  depends_on "cmake" => :build
  depends_on "fftw"
  depends_on "gsl" => :recommended
  depends_on :mpi => :optional
  depends_on :x11 => :optional

  def install
    args = std_cmake_args
    args << "-DGMX_GSL=ON" if build.with? "gsl"
    args << "-DGMX_MPI=ON" if build.with? "mpi"
    args << "-DGMX_DOUBLE=ON" if build.include? "enable-double"
    args << "-DGMX_X11=ON" if build.with? "x11"
    args << "-DGMX_CPU_ACCELERATION=None" if MacOS.version <= :snow_leopard
    args << "-DREGRESSIONTEST_DOWNLOAD=ON" unless build.with? "without-check"

    inreplace "scripts/CMakeLists.txt", "BIN_INSTALL_DIR", "DATA_INSTALL_DIR"

    system "mkdir", "build"

    cd "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "check" if build.with? "check"
      ENV.deparallelize
      system "make", "install"
    end

    bash_completion.install "build/scripts/GMXRC" => "gromacs-completion.bash"
    zsh_completion.install "build/scripts/GMXRC.zsh" => "_gromacs"
  end

  def caveats;  <<-EOS.undent
    GMXRC and other scripts installed to:
      #{HOMEBREW_PREFIX}/share/gromacs
    EOS
  end
end
