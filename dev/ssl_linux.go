package dev

import "fmt"

const supportDir = "~/.jewelcat-ssl"

func trustCert(cert string) error {
	fmt.Printf("! Add %s to your browser to trust CA\n", cert)
	return nil
}
