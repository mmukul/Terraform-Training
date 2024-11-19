output printfirst {
        value = "first user is ${join(",",var.users)}"
}

output helloworldupper {
        value = "first user is ${upper(var.users[0])}"
}

output helloworldlower {
        value = "first user is ${lower(var.users[0])}"
}

output helloworldtitle {
        value = "first user is ${title(var.users[0])}"
}