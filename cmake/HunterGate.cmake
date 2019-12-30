# Note: use -DHUNTER_ENABLED=NO to turn off the usage of Hunter.
include( cwm4/gate/cmake/HunterGate.cmake )

# Hunter Gate to use when Hunter is turned on.
HunterGate(
    URL "https://github.com/ruslo/hunter/archive/v0.23.214.tar.gz"
    SHA1 "e14bc153a7f16d6a5eeec845fb0283c8fad8c358"
)
