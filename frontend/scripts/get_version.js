const childProcess = require("child_process");
const fs = require("fs");


function writeRevision(sha) {
    fs.writeFile("src/revision.ts", `export const GIT_REVISION="${sha.trim()}";\n`, (err) => {
        if (err) console.log(err);
    });
}


(async () => {
    childProcess.exec("git rev-parse --short HEAD", (err, stdout) => {
        writeRevision(stdout);
    });
})();