#include <stdio.h>
#include <string.h>

static const char *artefactos[] = {
    "Archivo educativo - Cliente ACME",
    "Version 1.0",

    "/tmp/muestra.dat",
    "/var/tmp/update.tmp",

    "https://update.curso.local/api/v1/check",
    "api.curso.local",
    "192.168.56.20",

    "bash",
    "curl",

    "chrome",
    "firefox",
    "Login Data",
    "Cookies",

    "username",
    "password",
    "token",

    "/home/usuario/.bashrc",
    "/etc/cron.d/muestra-job",

    "ERROR: Unable to connect to server",
    "Downloading update...",
    "Checking credentials...",
    "Installation completed"
};

int main(void)
{
    volatile size_t keep_strings = 0;

    for (size_t i = 0;
         i < sizeof(artefactos) / sizeof(artefactos[0]);
         i++) {
        keep_strings += strlen(artefactos[i]);
    }

    printf("Archivo educativo\n");
    printf("Cliente: ACME\n");
    printf("Muestra procesada correctamente.\n");

    return keep_strings == 0;
}
