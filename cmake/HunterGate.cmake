# Note: use -DHUNTER_ENABLED=NO to turn off the usage of Hunter.
include( cwm4/gate/cmake/HunterGate.cmake )

# Hunter Gate to use when Hunter is turned on.
HunterGate(
    URL "https://github.com/cpp-pm/hunter/archive/v0.23.240.tar.gz"
    SHA1 "ca19f3769e6c80cfdd19d8b12ba5102c27b074e0"
)
