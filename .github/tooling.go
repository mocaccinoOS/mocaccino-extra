package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"sync"

	luetClient "github.com/mudler/luet/pkg/api/client"
	utils "github.com/mudler/luet/pkg/api/client/utils"
)

type opData struct {
	FinalRepo string
}

type resultData struct {
	Package luetClient.Package
	Exists  bool
}

func metaWorker(i int, wg *sync.WaitGroup, c <-chan luetClient.Package, o opData) error {
	defer wg.Done()

	for p := range c {
		tmpdir, err := ioutil.TempDir(os.TempDir(), "ci")
		checkErr(err)
		unpackdir, err := ioutil.TempDir(os.TempDir(), "ci")
		checkErr(err)
		utils.RunSH("unpack", fmt.Sprintf("TMPDIR=%s XDG_RUNTIME_DIR=%s luet util unpack %s %s", tmpdir, tmpdir, p.ImageMetadata(o.FinalRepo), unpackdir))
		utils.RunSH("move", fmt.Sprintf("mv %s/* build/", unpackdir))
		checkErr(err)
		os.RemoveAll(tmpdir)
		os.RemoveAll(unpackdir)
	}
	return nil
}

func buildWorker(i int, wg *sync.WaitGroup, c <-chan luetClient.Package, o opData, results chan<- resultData) error {
	defer wg.Done()

	for p := range c {
		fmt.Println("Checking", p)
		results <- resultData{Package: p, Exists: p.ImageAvailable(o.FinalRepo)}
	}
	return nil
}

func main() {
	finalRepo := os.Getenv("FINAL_REPO")
	packs, err := luetClient.TreePackages("./packages")
	checkErr(err)

	currentPackage := os.Getenv("CURRENT_PACKAGE")
	allPackages := os.Getenv("ALL_PACKAGES")

	if currentPackage != "" {
		for _, p := range packs.Packages {
			if p.EqualSV(currentPackage) && !p.ImageAvailable(finalRepo) {
				fmt.Println("Building", p.String())
				checkErr(utils.RunSH("build", fmt.Sprintf("./.github/build.sh %s", p.String())))
			}
		}
		os.Exit(0)
	}
	if allPackages == "true" {
		for _, p := range packs.Packages {
			if !p.ImageAvailable(finalRepo) {
				fmt.Println("Building", p.String())
				checkErr(utils.RunSH("build", fmt.Sprintf("./.github/build.sh %s", p.String())))
			}
		}
		os.Exit(0)
	}

	all := make(chan luetClient.Package)
	wg := new(sync.WaitGroup)

	for i := 0; i < 1; i++ {
		wg.Add(1)
		go metaWorker(i, wg, all, opData{FinalRepo: finalRepo})
	}

	for _, p := range packs.Packages {
		all <- p
	}
	close(all)
	wg.Wait()
}

func checkErr(err error) {
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
