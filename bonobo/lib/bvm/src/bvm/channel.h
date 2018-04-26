//
// Created by Tobe on 4/26/18.
//

#ifndef PROJECT_CHANNEL_H
#define PROJECT_CHANNEL_H


namespace bvm
{
    class Channel
    {
    public:
        virtual void notifyMissingMethod(const char *str) = 0;

        virtual void shutdown() = 0;

        virtual void throwString(const char *str) = 0;
    };
}


#endif //PROJECT_CHANNEL_H
