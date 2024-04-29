output "db_client_sg" {
    value = aws_security_group.db_client_sg
}

output "wp_fs_client_sg" {
    value = aws_security_group.wp_fs_client_sg
}