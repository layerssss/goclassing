@echo off
call icake build
call icake static
call icake crude
call icake -o ./release deploy